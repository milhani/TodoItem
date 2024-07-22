import Foundation


public protocol NetworkingServiceProtocol {
    func getList() async throws -> [TodoItem]
    func updateList(with items: [TodoItem]) async throws -> [TodoItem]
    func getItem(withId id: String, item: TodoItem) async throws -> TodoItem
    func addItem(_ item: TodoItem) async throws -> TodoItem
    func updateItem(withId id: String, item: TodoItem) async throws -> TodoItem
    func deleteItem(withId id: String) async throws -> TodoItem
}

