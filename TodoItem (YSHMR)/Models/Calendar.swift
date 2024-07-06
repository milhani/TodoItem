import Foundation


struct Calendar {
    let id: String
    var text: String
    let deadLine: Date?
    let isDone: Bool
    let category: Category?
    
    init(_ item: TodoItem) {
        id = item.id
        text = item.text
        deadLine = item.deadline
        isDone = item.isDone
        category = item.category
    }
}
