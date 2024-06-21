import Foundation


enum Importance: String {
    case low
    case normal
    case important
}

enum Keys: String {
    case id
    case text
    case importance
    case deadline
    case isDone
    case createdAt
    case updatedAt
}


struct TodoItem {
    var id: String
    var text: String
    var importance: Importance
    var deadline: Date?
    var isDone: Bool
    var createdAt: Date
    var updatedAt: Date?
    
    init(id: String = UUID().uuidString,
         text: String,
         importance: Importance = .normal,
         deadline: Date? = nil,
         isDone: Bool = false,
         createdAt: Date = Date(),
         updatedAt: Date? = nil)
    {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.createdAt = createdAt
        self.updatedAt = updatedAt
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
        
        return TodoItem(id: id, text: text, importance: importance, deadline: deadline, isDone: isDone, createdAt: createdAt, updatedAt: updatedAt)
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
        
        return jsonDict
    }
}


extension TodoItem {
    private static let csvSeparator = ","
    
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
        
        if data.count < 1 { return nil }
        
        let createdAt: Date
        guard let csvCreatedAt = dateFormatter.date(from: data[0]) else { return nil }
        createdAt = csvCreatedAt
        
        let updatedAt: Date?
        if data.count == 2 {
            guard let csvUpdatedAt = dateFormatter.date(from: data[1]) else { return nil }
            updatedAt = csvUpdatedAt
        } else {
            updatedAt = nil
        }

        return TodoItem(id: id, text: text, importance: importance, deadline: deadline, isDone: isDone, createdAt: createdAt, updatedAt: updatedAt)
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
            csvString.append(String(deadline.timeIntervalSince1970))
        }

        csvString.append(String(isDone))
        csvString.append(String(createdAt.timeIntervalSince1970))

        if let updatedAt = updatedAt {
            csvString.append(String(updatedAt.timeIntervalSince1970))
        }

        return csvString.joined(separator: Self.csvSeparator)
    }
}
