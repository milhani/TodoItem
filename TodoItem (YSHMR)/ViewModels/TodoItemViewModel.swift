import SwiftUI
import CocoaLumberjackSwift
import MyLibrary

class TodoItemViewModel: ObservableObject {

    @Published var text: String
    @Published var importance: Importance
    @Published var deadline: Date?
    @Published var updatedAt: Date?
    @Published var color: Color
    @Published var category: Category
    
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
    var fileCache: FileCache<TodoItem>
    private var calendarViewController: CalendarViewController?
    weak var delegate: TodoListViewControllerDelegate?

    init(todoItem: TodoItem, fileCache: FileCache<TodoItem>,
         calendarViewController: CalendarViewController? = nil) {
        self.todoItem = todoItem
        self.fileCache = fileCache
        self.text = todoItem.text
        self.importance = todoItem.importance
        self.deadline = todoItem.deadline
        self.updatedAt = todoItem.updatedAt
        self.isDeadlineEnabled = todoItem.deadline != nil
        self.selectedDeadline = todoItem.deadline ?? Date() + 86400
        self.color = Color(hex: todoItem.color)
        self.category = todoItem.category
        if let calendarViewController {
            self.calendarViewController = calendarViewController
            self.delegate = calendarViewController
        }
    }

    func saveItem() {
        let newItem = TodoItem(id: todoItem.id, text: text, importance: importance,
                               deadline: deadline, isDone: todoItem.isDone, createdAt: todoItem.createdAt,
                               updatedAt: updatedAt, color: color.hex, category: category)
        fileCache.add(newItem)
        
        do {
            try fileCache.save(to: "items.json", format: .json)
            delegate?.didUpdateTodoList()
            DDLogInfo("Новая заметка \(newItem) сохранена в \(Self.self)")
        } catch {
            DDLogError("Ошибка сохранения в \(Self.self)")
        }
    }

    func removeItem() {
        fileCache.remove(todoItem.id)
        try? fileCache.save(to: "items.json", format: .json)
        delegate?.didUpdateTodoList()
        
        do {
            try fileCache.save(to: "items.json", format: .json)
            delegate?.didUpdateTodoList()
            DDLogInfo("Заметка была удалена, инвормация сохранена в \(Self.self)")
        } catch {
            DDLogError("Ошибка сохранения в \(Self.self)")
        }
    }

}
