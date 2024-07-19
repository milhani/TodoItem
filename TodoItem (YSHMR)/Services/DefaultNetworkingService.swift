import Foundation


struct DefaultNetworkingService {
    private let baseURL = "https://hive.mrdekk.ru/todo/"
    private let authorizationToken = "Haleth"
    
    private let urlSession = URLSession(configuration: .default)
    private let storage = Storage()
    
    static var shared = DefaultNetworkingService()
    
    private init() { }
    
    private func makeRequest(_ endpoint: String, method: String, body: Data? = nil, withRevision: Bool) async -> URLRequest {
        let url = URL(string: "\(baseURL)/\(endpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.setValue("Bearer \(authorizationToken)", forHTTPHeaderField: "Authorization")
        
        if withRevision {
            let lastKnownRevision = await storage.getRevision()
            var headers = request.allHTTPHeaderFields ?? [:]
            headers["X-Last-Known-Revision"] = "\(lastKnownRevision)"
            request.allHTTPHeaderFields = headers
        }
        return request
    }
    
    private func retryRequestWithItem(_ request: URLRequest, count: Int = 0) async throws -> TodoItem {
        let delay = min(2.0 * 20.0 * Double(count), 120.0)
        let jitter = Double.random(in: 0.0...0.05)
        let totalDelay = delay * (1.0 + jitter)
        try await Task.sleep(nanoseconds: UInt64(totalDelay * 1000000))
        do {
            var newRequest = request
            let lastKnownRevision = await storage.getRevision()
            var headers = request.allHTTPHeaderFields ?? [:]
            headers["X-Last-Known-Revision"] = "\(lastKnownRevision)"
            newRequest.allHTTPHeaderFields = headers
            
            let (data, _) = try await urlSession.dataTask(for: newRequest)
            return try await parseItem(from: data)
        } catch {
            if count < 3 {
                return try await retryRequestWithItem(request, count: count + 1)
            }
            throw error
        }
    }
    
    private func parseItem(from data: Data) async throws -> TodoItem {
        let json = try JSONSerialization.jsonObject(with: data)
        guard let json = json as? [String: Any],
              let revision = json[Keys.revision.rawValue] as? Int,
              let element = json[Keys.element.rawValue] as? [String: Any],
              let item = TodoItem.parse(json: element)
        else {
            throw URLError(.cannotDecodeContentData)
        }
        await storage.updateRevision(newRevision: revision)
        return item
    }
    
    private func retryRequestWithItems(_ request: URLRequest, count: Int = 0) async throws -> [TodoItem] {
        let delay = min(2.0 * 20.0 * Double(count), 120.0)
        let jitter = Double.random(in: 0.0...0.05)
        let totalDelay = delay * (1.0 + jitter)
        try await Task.sleep(nanoseconds: UInt64(totalDelay * 1000000))
        do {
            var newRequest = request
            let lastKnownRevision = await storage.getRevision()
            var headers = request.allHTTPHeaderFields ?? [:]
            headers["X-Last-Known-Revision"] = "\(lastKnownRevision)"
            newRequest.allHTTPHeaderFields = headers

            let (data, _) = try await urlSession.data(for: newRequest)
            return try await parseItems(from: data)
        } catch {
            if count < 3 {
                return try await retryRequestWithItems(request, count: count + 1)
            }
            throw error
        }
    }
    
    private func parseItems(from data: Data) async throws -> [TodoItem] {
        let json = try JSONSerialization.jsonObject(with: data)
        guard let json = json as? [String: Any],
              let revision = json[Keys.revision.rawValue] as? Int,
              let list = json[Keys.list.rawValue] as? [[String: Any]]
        else {
            throw URLError(.cannotDecodeContentData)
        }
        
        var todoItems: [TodoItem] = []
        for jsonObject in list {
            guard let todoItem = TodoItem.parse(json: jsonObject) else {
                throw URLError(.cannotDecodeContentData)
            }
            todoItems.append(todoItem)
        }
        await storage.updateRevision(newRevision: revision)
        return todoItems
    }
}

extension DefaultNetworkingService: NetworkingServiceProtocol {
    func getList() async throws -> [TodoItem] {
        let request = await makeRequest("list", method: "GET", withRevision: false)
        return try await retryRequestWithItems(request)
    }
    
    func updateList(with items: [TodoItem]) async throws -> [TodoItem] {
        let jsonItems = items.map { $0.json }
        let request = await makeRequest("list", method: "PATCH", body: try JSONSerialization.data(withJSONObject: ["list": jsonItems]), withRevision: true)
        return try await retryRequestWithItems(request)
    }
    
    func getItem(withId id: String, item: TodoItem) async throws -> TodoItem {
        let request = await makeRequest("list/\(id)", method: "POST", body: try JSONSerialization.data(withJSONObject: ["element": item.json]), withRevision: true)
        return try await retryRequestWithItem(request)
    }
    
    func addItem(_ item: TodoItem) async throws -> TodoItem {
        let request = await makeRequest("list", method: "POST", body: try JSONSerialization.data(withJSONObject: ["element": item.json]), withRevision: true)
        return try await retryRequestWithItem(request)
    }
    
    func updateItem(withId id: String, item: TodoItem) async throws -> TodoItem {
        let request = await makeRequest("list/\(id)", method: "PUT", body: try JSONSerialization.data(withJSONObject: ["element": item.json]), withRevision: true)
        return try await retryRequestWithItem(request)
    }
    
    func deleteItem(withId id: String) async throws -> TodoItem {
        let request = await makeRequest("list/\(id)", method: "DELETE", withRevision: true)
        return try await retryRequestWithItem(request)
    }
}

