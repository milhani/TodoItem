import SwiftUI

class TodoItemViewModel: ObservableObject {

    @Published var text: String
    @Published var importance: Importance
    @Published var deadline: Date?
    @Published var updatedAt: Date?
    @Published var color: Color
    
    @Published var selectedDeadline: Date = Date() + 86400 {
        didSet {
            deadline = isDeadlineEnabled ? selectedDeadline : nil
        }
    }
    @Published var isDeadlineEnabled: Bool {
        didSet {
            selectedDeadline = isDeadlineEnabled ? (todoItem.deadline ?? Date() + 86400) : Date() + 86400
            deadline = isDeadlineEnabled ? selectedDeadline : nil
        }
    }

    var isNew: Bool { fileCache.items[todoItem.id] == nil }

    private let todoItem: TodoItem
    private let fileCache: FileCache

    init(todoItem: TodoItem, fileCache: FileCache = FileCache.shared) {
        self.todoItem = todoItem
        self.fileCache = fileCache
        self.text = todoItem.text
        self.importance = todoItem.importance
        self.deadline = todoItem.deadline
        self.updatedAt = todoItem.updatedAt
        self.isDeadlineEnabled = todoItem.deadline != nil
        self.selectedDeadline = todoItem.deadline ?? Date() + 86400
        self.color = Color(hex: todoItem.color)
    }

    func saveItem() {
        let newItem = TodoItem(id: todoItem.id, text: text, importance: importance,
                               deadline: deadline, isDone: todoItem.isDone, createdAt: todoItem.createdAt,
                               updatedAt: updatedAt, color: color.hex)
        fileCache.add(newItem)
        try? fileCache.save(to: "items.json", format: .json)
    }

    func removeItem() {
        fileCache.remove(todoItem.id)
        try? fileCache.save(to: "items.json", format: .json)
    }

}
