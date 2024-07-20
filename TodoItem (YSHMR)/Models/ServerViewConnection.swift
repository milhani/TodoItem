import Foundation
import MyLibrary


class ServerViewConnection {
    let fileCache: FileCache<TodoItem>
    let networkService: NetworkingServiceProtocol

    init(fileCache: FileCache<TodoItem>, networkService: NetworkingServiceProtocol) {
        self.fileCache = fileCache
        self.networkService = networkService
    }
    
    func saveLocally(item: TodoItem) -> [TodoItem] {
        fileCache.add(item)
        return fileCache.load() ?? []
    }
    
    func save(item: TodoItem) async throws {
        let newItem = try await networkService.addItem(item)
        print("ServerViewConnection", newItem)
    }
    
    func getLocally() -> [TodoItem] {
        return fileCache.load() ?? []
    }
    
    func get() async throws -> [TodoItem] {
        try await networkService.getList()
    }
    
    func deleteLocally(id: String) -> [TodoItem] {
        fileCache.remove(id)
        return fileCache.load() ?? []
    }
    
    func delete(id: String) async throws {
        let _ = try await networkService.deleteItem(withId: id)
    }
    
    func updateItem(item: TodoItem) async throws {
        let _ = try await networkService.updateItem(withId: item.id, item: item)
    }
    
    func updateItems() async throws -> [TodoItem] {
        try await networkService.updateList(with: fileCache.load() ?? [])
    }
    
    func setItemDirty(_ isDirty: Bool) {
        fileCache.setDirty(isDirty)
    }
    
    func isItemDirty() -> Bool {
        fileCache.getIsDirty()
    }
}
