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
    @Published var fileCache: FileCache<TodoItem>
    
    @Published var chosenSorting: Bool = true
    @Published var sortType: SortType = .importanceSort
    @Published var isUpdateCalendar = false
    
    var items: [TodoItem] {
        changeItems(items: Array(fileCache.items.values))
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
        fileCache.items.values.filter({ $0.isDone }).count
    }

    init(fileCache: FileCache<TodoItem>) {
        self.fileCache = fileCache
        try? self.fileCache.load(from: "items.json", format: .json)
    }

    func addItem(_ item: TodoItem) {
        fileCache.add(item)
        
        do {
            try fileCache.save(to: "items.json", format: .json)
            isUpdateCalendar = true
            DDLogInfo("Новая заметка \(item) сохранена в \(Self.self)")
        } catch {
            DDLogError("Ошибка сохранения в \(Self.self)")
        }
        
    }

    func delete(_ item: TodoItem) {
        fileCache.remove(item.id)

        do {
            try fileCache.save(to: "items.json", format: .json)
            DDLogInfo("Заметка была удалена, инвормация сохранена в \(Self.self)")
        } catch {
            DDLogError("Ошибка сохранения в \(Self.self)")
        }
    }

    func toggleShowCompleted() {
        chosenSorting.toggle()
    }
    
    func toggleDone(_ item: TodoItem) {
        let newItem = TodoItem(id: item.id, text: item.text, importance: item.importance,
                               deadline: item.deadline, isDone: !item.isDone, createdAt: item.createdAt,
                               updatedAt: item.updatedAt, color: item.color)
        fileCache.add(newItem)
        
        do {
            try fileCache.save(to: "items.json", format: .json)
            DDLogInfo("Заметка поменяла статус выполнения на \(newItem.isDone)")
        } catch {
            DDLogError("Ошибка сохранения в \(Self.self)")
        }
    }

    func changeImportance() {
        if sortType == .importanceSort {
            sortType = .addSort
        } else {
            sortType = .importanceSort
        }
    }
    
    func checkItems() {
        isUpdateCalendar = true
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
