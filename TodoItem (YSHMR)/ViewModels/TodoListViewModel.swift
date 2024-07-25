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
    
    @Published var tasks: [TodoItem] = []
    @Published var sortedTasks: [TodoItem] = []
    
    init(connection: ServerViewConnection) {
        self.connection = connection
        print("INITED")
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
    
    func reloadItems() {
        print("RELOAD")
        loadTasksFromServer()
    }

    func addItem(_ item: TodoItem) {
        tasks.append(item)
        _ = connection.saveLocally(item: item)
        
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
        self.sortedTasks = changeItems(items: tasks)
    }
    
    func updateItem(_ item: TodoItem) {
        let oldItemIndex = tasks.firstIndex(where: {$0.id == item.id})
        if oldItemIndex == nil {
            return
        }
        tasks[oldItemIndex!] = item
        _ = connection.saveLocally(item: item)
        
        guard !connection.fileCache.getIsDirty() else {
            return reloadDirtyList()
        }
        
        Task.detached(operation: { [weak self] in
            do {
                try await self?.connection.updateItem(item: item)
                self?.isUpdateCalendar = true
                DDLogInfo("Заметка \(item) изменена в \(Self.self)")
            } catch {
                self?.connection.fileCache.setDirty(true)
                DDLogError("Ошибка изменения в \(Self.self)")
            }
        })
       self.sortedTasks = changeItems(items: tasks)
    }

    func delete(_ item: TodoItem) {
        let itemIndex = tasks.firstIndex(where: {$0.id == item.id})
        if itemIndex == nil {
            return
        }
        tasks.remove(at: itemIndex!)
        _ = connection.deleteLocally(id: item.id)
        
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
        self.sortedTasks = changeItems(items: tasks)
        //reloadItems()
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
        sortedTasks = changeItems(items: self.tasks)
    }
    
    func toggleDone(_ item: TodoItem) {
        let newItem = TodoItem(id: item.id, text: item.text, importance: item.importance,
                               deadline: item.deadline, isDone: !item.isDone, createdAt: item.createdAt,
                               updatedAt: item.updatedAt, color: item.color)
        updateItem(newItem)
        //reloadView()
        //reloadItems()
    }

    func changeImportance() {
        if sortType == .importanceSort {
            sortType = .addSort
        } else {
            sortType = .importanceSort
        }
        sortedTasks = changeItems(items: self.tasks)
        //reloadItems()
    }
    
    func checkItems() {
        isUpdateCalendar = true
        //reloadItems()
    }
    
    func reloadView() {
        loadTasksLocally()
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

    
    func loadTasksFromServer() {
        Task.detached(operation: { [weak self] in
            do {
                if let tasks = try await self?.connection.get() {
                    //let sortedTasks = self!.changeItems(items: tasks)
                    self?.tasks = tasks
//                    var lst: [String: TodoItem] = [:]
//                    for el in tasks {
//                        lst[el.id] = el
//                    }
//                    self?.connection.fileCache.todoItems = lst
                    self?.sortedTasks = self?.changeItems(items: tasks) ?? tasks
                }
            } catch {
                self?.loadTasksLocally()
                self?.connection.fileCache.setDirty(true)
            }
        })
    }
    
    func loadTasksLocally() {
        let tasks = connection.getLocally()
        self.tasks = tasks
        self.sortedTasks = changeItems(items: tasks)
    }

}
