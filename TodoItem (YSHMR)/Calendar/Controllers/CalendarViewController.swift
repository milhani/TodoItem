import UIKit
import SwiftUI
import CocoaLumberjackSwift


struct dateSection {
    let date: String
    let todos: [TodoItem]
}

final class CalendarViewController: UIViewController {
    var todoListViewModel: TodoListViewModel
    
    lazy var contentView: CalendarView = {
        let contentView = CalendarView()
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.button.addTarget(self, action: #selector(openTodoItemView), for: .touchUpInside)
        return contentView
    }()
    
    lazy var dates: [String] = {
        var dates = dict.keys.filter({ $0 != "Другое" }).sorted()
        dates.append("Другое")
        return dates
    }()
    
    lazy var dict: [String: [TodoItem]] = {
        var grouped: [String: [TodoItem]] = [:]
        
        for item in todoListViewModel.items {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            let keyDict: String
            
            if let deadline = item.deadline {
                keyDict = dateFormatter.string(from: deadline)
            } else {
                keyDict = "Другое"
            }
            
            grouped[keyDict, default: []].append(item)
        }
        return grouped
    }()
    
    var sections: [dateSection] = []
    
    init (todoListviewModel: TodoListViewModel) {
        self.todoListViewModel = todoListviewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sortedDates = dict.keys.sorted()
        for date in sortedDates {
            sections.append(dateSection(date: date, todos: dict[date] ?? []))
        }
        
    }
    
    override func loadView() {
        view = contentView
        DDLogInfo("Загрузка экрана календаря \(Self.self)")
    }
    
    func sectionsUpdate() {
        var grouped: [String: [TodoItem]] = [:]
        for item in todoListViewModel.items {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            let keyDict: String
            
            if let deadline = item.deadline {
                keyDict = dateFormatter.string(from: deadline)
            } else {
                keyDict = "Другое"
            }
            
            grouped[keyDict, default: []].append(item)
        }
        dict = grouped
        
        var newDates = dict.keys.filter({ $0 != "Другое" }).sorted()
        newDates.append("Другое")
        dates = newDates
        
        sections = [dateSection]()
        let sortedDates = dict.keys.sorted()
        for date in sortedDates {
            sections.append(dateSection(date: date, todos: dict[date] ?? []))
        }
        DDLogInfo("Обновление секций с делами \(sections)")
    }
    
    func didSwipe(at indexPath: IndexPath, isLeading: Bool) {
        let selectedItem = sections[indexPath.section].todos[indexPath.row]
        
        let updatedItem = TodoItem(
            id: selectedItem.id,
            text: selectedItem.text,
            importance: selectedItem.importance,
            deadline: selectedItem.deadline,
            isDone: isLeading,
            createdAt: selectedItem.createdAt,
            updatedAt: selectedItem.updatedAt,
            color: selectedItem.color,
            category: selectedItem.category
        )
        
        todoListViewModel.delete(selectedItem)
        todoListViewModel.addItem(updatedItem)
        sectionsUpdate()
        DDLogInfo("Обновление заметки с \(selectedItem) на \(updatedItem)")
    }
}

