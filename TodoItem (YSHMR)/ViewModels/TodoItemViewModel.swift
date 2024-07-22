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

    var isNew: Bool { connection.fileCache.todoItems[todoItem.id] == nil }

    private let todoItem: TodoItem
    private var calendarViewController: CalendarViewController?
    private var connection: ServerViewConnection
    weak var delegate: TodoListViewControllerDelegate?
    
    init(todoItem: TodoItem, connection: ServerViewConnection,
         calendarViewController: CalendarViewController? = nil) {
        self.todoItem = todoItem
        self.connection = connection
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
        
        _ = connection.saveLocally(item: newItem)
        
        Task.detached(operation: { [weak self] in
            do {
                try await self?.connection.save(item: newItem)
                self?.delegate?.didUpdateTodoList()
                print("СОХРАНИЛОСЬ")
            } catch {
                self?.connection.fileCache.setDirty(true)
                print("НЕ СОХРАНИЛОСЬ")
            }
        })
    }
    
    func removeItem() {
        _ = connection.deleteLocally(id: todoItem.id)
        
        Task.detached(operation: { [weak self] in
            do {
                try await self?.connection.delete(id: self!.todoItem.id)
                self?.delegate?.didUpdateTodoList()
            } catch {
                self?.connection.fileCache.setDirty(true)
            }
        })
    }
}
