import Foundation


enum FileCacheErrors: Error {
    case cannotFindDocumentDirectory
    case incorrectData
}

enum Format {
    case json
    case csv
}


final class FileCache {
    private(set) var items: [String: TodoItem] = [:]
    
    func add(_ item: TodoItem) {
        items[item.id] = item
    }
    
    func remove(_ id: String) {
        guard items[id] != nil else { return }
        items.removeValue(forKey: id)
    }
    
    func save(to file: String, format: Format) throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            throw FileCacheErrors.cannotFindDocumentDirectory
        }
        
        let path = documentDirectory.appendingPathComponent(file)
        
        switch format {
        case .json:
            let serializedItems = items.map { _, item in item.json }
            let data = try JSONSerialization.data(withJSONObject: serializedItems, options: [])
            try data.write(to: path)
        case .csv:
            var data = TodoItem.csvHeadLine
            data += items.map { _, item in item.csv }.joined(separator: "\n")
            try data.write(to: path, atomically: true, encoding: .utf8)
        }
    }
    
    func load(from file: String, format: Format) throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            throw FileCacheErrors.cannotFindDocumentDirectory
        }
        
        let path = documentDirectory.appendingPathComponent(file)
        
        switch format {
        case .json:
            let data = try Data(contentsOf: path)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let json = json as? [Any] else { throw FileCacheErrors.incorrectData }
            let newItems = json.compactMap { TodoItem.parse(json: $0) }
            self.items = newItems.reduce(into: [String: TodoItem]()) { newArray, item in
                newArray[item.id] = item
            }
        case .csv:
            var data = try String(contentsOf: path).components(separatedBy: "\n")
            guard !data.isEmpty else { throw FileCacheErrors.incorrectData }
            data.removeFirst()
            let newItems = data.compactMap { TodoItem.parse(csv: $0) }
            self.items = newItems.reduce(into: [String: TodoItem]()) { newArray, item in
                newArray[item.id] = item
            }
        }
    }
}
