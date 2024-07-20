import SwiftUI
import MyLibrary
import CocoaLumberjackSwift


enum SortType: String {
    case addSort = "Сортировка по добавлению"
    case importanceSort = "Сортировка по важности"
}


final class TodoListViewModel: ObservableObject {

    @Published var todoViewPresented: Bool = false {
        didSet {
            if !todoViewPresented {
                selectedItem = nil
            }
        }
    }
    @Published var selectedItem: TodoItem?
    @Published var newTodo: String = ""

    var connection: ServerViewConnection
    
    @Published var chosenSorting: Bool = true
    @Published var sortType: SortType = .importanceSort
    @Published var isUpdateCalendar = false
    
    var tasks: [TodoItem] = []
    
    init(connection: ServerViewConnection) {
        self.connection = connection
        reloadItems()
    }
    
    var openedItem: TodoItem {
        if let selectedItem {
            return selectedItem
        }
        return TodoItem(
            id: UUID().uuidString,
            text: "",
            importance: .normal,
            deadline: nil,
            isDone: false,
            createdAt: .now,
            updatedAt: nil,
            color: "#fefefeff"
        )
    }

    var doneCounter: Int {
        connection.fileCache.todoItems.values.filter({ $0.isDone }).count
    }
    
    private func reloadItems() {
        let tasks = connection.getLocally()
        let sortedTasks = changeItems(items: tasks)
        self.tasks = sortedTasks
        
        guard !connection.fileCache.getIsDirty() else {
            return reloadDirtyList()
        }
        
        Task.detached(operation: { [weak self] in
            do {
                if let tasks = try await self?.connection.get() {
                    let sortedTasks = self!.changeItems(items: tasks)
                    self?.tasks = sortedTasks
                    var lst: [String: TodoItem] = [:]
                    for el in tasks {
                        lst[el.id] = el
                    }
                    self?.connection.fileCache.todoItems = lst
                }
            } catch {
                self?.connection.fileCache.setDirty(true)
            }
        })
    }

    func addItem(_ item: TodoItem) {
        _ = connection.saveLocally(item: item)
        reloadItems()
        
        guard !connection.fileCache.getIsDirty() else {
            return reloadDirtyList()
        }
        
        Task.detached(operation: { [weak self] in
            do {
                try await self?.connection.save(item: item)
                self?.isUpdateCalendar = true
                DDLogInfo("Новая заметка \(item) сохранена в \(Self.self)")
            } catch {
                self?.connection.fileCache.setDirty(true)
                DDLogError("Ошибка сохранения в \(Self.self)")
            }
        })
    }

    func delete(_ item: TodoItem) {
        _ = connection.deleteLocally(id: item.id)
        reloadItems()
        
        guard !connection.fileCache.getIsDirty() else {
            return reloadDirtyList()
        }
        
        Task.detached(operation: { [weak self] in
            do {
                try await self?.connection.delete(id: item.id)
                DDLogInfo("Заметка была удалена, инвормация сохранена в \(Self.self)")
            } catch {
                self?.connection.fileCache.setDirty(true)
                DDLogError("Ошибка сохранения в \(Self.self)")
            }
        })
    }
    
    func reloadDirtyList() {
        Task.detached(operation: { [weak self] in
            do {
                let items = try await self?.connection.updateItems()
                if let items = items {
                    var lst: [String: TodoItem] = [:]
                    for el in items {
                        lst[el.id] = el
                    }
                    self?.connection.fileCache.todoItems = lst
                }
                self?.connection.fileCache.setDirty(false)
            } catch {
                self?.connection.fileCache.setDirty(true)
            }
        })
    }

    func toggleShowCompleted() {
        chosenSorting.toggle()
    }
    
    func toggleDone(_ item: TodoItem) {
        let newItem = TodoItem(id: item.id, text: item.text, importance: item.importance,
                               deadline: item.deadline, isDone: !item.isDone, createdAt: item.createdAt,
                               updatedAt: item.updatedAt, color: item.color)
        addItem(newItem)
        //reloadView()
        reloadItems()
        
    }

    func changeImportance() {
        if sortType == .importanceSort {
            sortType = .addSort
        } else {
            sortType = .importanceSort
        }
        reloadItems()
    }
    
    func checkItems() {
        isUpdateCalendar = true
        reloadItems()
    }
    
    func reloadView() {
        let tasks = connection.getLocally()
        let sortedTasks = changeItems(items: tasks)
        self.tasks = sortedTasks
    }

    private func changeItems(items: [TodoItem]) -> [TodoItem] {
        var result = switch sortType {
        case .addSort:
            items.sorted { $0.importance > $1.importance }
        case .importanceSort:
            items.sorted { $0.createdAt < $1.createdAt }
        }
        if !chosenSorting {
            result = result.filter { !$0.isDone }
        }
        DDLogInfo("Изменение ключа сортировки")
        return result
    }

}
