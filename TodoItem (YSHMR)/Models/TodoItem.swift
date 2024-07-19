import SwiftUI
import MyLibrary


enum Importance: String, CaseIterable, Identifiable, Comparable {
    case low
    case normal
    case important
    
    private static func compare(_ lhs: Self, _ rhs: Self) -> Self {
        switch (lhs, rhs) {
        case (.low, _), (_, .low):
            return .low
        case (.normal, _), (_, .normal):
            return .normal
        case (.important, _), (_, .important):
            return .important
        }
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        return (lhs != rhs) && (lhs == Self.compare(lhs, rhs))
    }

    var id: Self { self }

    var symbol: AnyView {
        switch self {
        case .low: AnyView(Image(.importanceLow))
        case .normal: AnyView(Text("нет"))
        case .important: AnyView(Image(.importanceHigh))
        }
    }
}


enum Keys: String {
    case id
    case text
    case importance
    case deadline
    case isDone
    case createdAt
    case updatedAt
    case color
    case category
}


struct TodoItem: Identifiable {
    
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let createdAt: Date
    let updatedAt: Date?
    let color: String
    let category: Category
    
    init(id: String?,
         text: String,
         importance: Importance = .normal,
         deadline: Date? = nil,
         isDone: Bool?,
         createdAt: Date = Date(),
         updatedAt: Date? = nil,
         color: String?,
         category: Category? = nil)
    {
        self.id = id ?? UUID().uuidString
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone ?? false
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.color = color ?? "#fefefeff"
        self.category = category ?? Category.defaultCategories.first!
    }
}


extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard
            let json = json as? [String: Any],
            let id = json[Keys.id.rawValue] as? String,
            let text = json[Keys.text.rawValue] as? String,
            let createdAt = (json[Keys.createdAt.rawValue] as? Int).flatMap({ Date(timeIntervalSince1970: TimeInterval($0)) })
        else {
            return nil
        }
        
        let importance = (json[Keys.importance.rawValue] as? String).flatMap(Importance.init(rawValue:)) ?? .normal
        let deadline = (json[Keys.deadline.rawValue] as? Int).flatMap({ Date(timeIntervalSince1970: TimeInterval($0)) })
        let isDone = json[Keys.isDone.rawValue] as? Bool ?? false
        let updatedAt = (json[Keys.updatedAt.rawValue] as? Int).flatMap({ Date(timeIntervalSince1970: TimeInterval($0)) })
        let color = json[Keys.color.rawValue] as? String ?? "#fefefeff"
        let category = json[Keys.category.rawValue] as? String ?? "Другое"
        
        var categoryColor: String = "#FFFFFF"
        for cat in Category.defaultCategories {
            if cat.name == category {
                categoryColor = cat.color
            }
        }
        
        return TodoItem(id: id, text: text, importance: importance, deadline: deadline, isDone: isDone, createdAt: createdAt, updatedAt: updatedAt, color: color, category: Category(name: category, color: categoryColor))
    }
    
    var json: Any {
        var jsonDict = [String: Any]()
        
        jsonDict[Keys.id.rawValue] = id
        jsonDict[Keys.text.rawValue] = text
        
        switch importance {
        case .low, .important:
            jsonDict[Keys.importance.rawValue] = importance.rawValue
        case .normal:
            break
        }
        
        if let deadline = deadline {
            jsonDict[Keys.deadline.rawValue] = Int(deadline.timeIntervalSince1970)
        }
        
        jsonDict[Keys.isDone.rawValue] = isDone
        jsonDict[Keys.createdAt.rawValue] = Int(createdAt.timeIntervalSince1970)
        
        if let updatedAt = updatedAt {
            jsonDict[Keys.updatedAt.rawValue] = Int(updatedAt.timeIntervalSince1970)
        }
        
        jsonDict[Keys.color.rawValue] = color
        jsonDict[Keys.category.rawValue] = category.name
        
        return jsonDict
    }
}


extension TodoItem {
    private static let csvSeparator = ","
    
    var csvHeadLine: String {
        var headline = [String]()
        headline.append(Keys.id.rawValue)
        headline.append(Keys.text.rawValue)
        headline.append(Keys.importance.rawValue)
        headline.append(Keys.deadline.rawValue)
        headline.append(Keys.isDone.rawValue)
        headline.append(Keys.createdAt.rawValue)
        headline.append(Keys.updatedAt.rawValue)
        return headline.joined(separator: Self.csvSeparator) + "\n"
        }
    
    static func parse(csv: String) -> TodoItem? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        var data = csv.components(separatedBy: Self.csvSeparator)
        
        if data.count < 5 { return nil }
        
        let id = data[0]
        
        var textPieces = [String]()
        for ind in 1..<data.count {
            let el = data[ind]
            if let _ = Importance(rawValue: el) { break }
            if el == "" { break }
            textPieces.append(el)
        }
        let text = textPieces.joined(separator: Self.csvSeparator)
        data.removeSubrange(0...textPieces.count)
        
        if data.count < 3 { return nil }
        
        let importance: Importance
        if let csvImportance = Importance(rawValue: data[0]) {
            importance = csvImportance
        } else {
            importance = .normal
        }
        
        let deadline: Date?
        let isDone: Bool
        if let csvIsDone = Bool(data[1]) {
            deadline = nil
            isDone = csvIsDone
            data.removeSubrange(0...1)
        } else {
            deadline = dateFormatter.date(from: data[1])
            isDone = Bool(data[2]) ?? false
            data.removeSubrange(0...2)
        }
        
        if data.count < 2 { return nil }
        
        let createdAt: Date
        guard let csvCreatedAt = dateFormatter.date(from: data[0]) else { return nil }
        createdAt = csvCreatedAt
        
        let updatedAt: Date?
        updatedAt = dateFormatter.date(from: data[1])

        return TodoItem(id: id, text: text, importance: importance, deadline: deadline, isDone: isDone, createdAt: createdAt, updatedAt: updatedAt, color: nil)
    }

    var csv: String {
        var csvString = [String]()

        csvString.append(id)
        csvString.append(text)

        switch importance {
        case .low, .important:
            csvString.append(importance.rawValue)
        case .normal:
            csvString.append("")
        }

        if let deadline = deadline {
            csvString.append(String(Int(deadline.timeIntervalSince1970)))
        }

        csvString.append(String(isDone))
        csvString.append(String(Int(createdAt.timeIntervalSince1970)))

        if let updatedAt = updatedAt {
            csvString.append(String(Int(updatedAt.timeIntervalSince1970)))
        } else {
            csvString.append("")
        }

        return csvString.joined(separator: Self.csvSeparator)
    }
}
