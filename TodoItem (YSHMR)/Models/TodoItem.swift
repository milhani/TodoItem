//
//  Todoitem.swift
//  TodoItem (YSHMR)
//
//  Created by Людмила Ханина on 17.06.2024.
//



import Foundation


enum Importance: String {
    case low
    case normal
    case important
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
            let id = json["id"] as? String,
            let text = json["text"] as? String,
            let createdAt = (json["createdAt"] as? Int).flatMap({ Date(timeIntervalSince1970: TimeInterval($0)) })
        else {
            return nil
        }
        
        let importance = (json["importance"] as? String).flatMap(Importance.init(rawValue:)) ?? .normal
        let deadline = (json["deadline"] as? Int).flatMap({ Date(timeIntervalSince1970: TimeInterval($0)) })
        let isDone = json["isDone"] as? Bool ?? false
        let updatedAt = (json["updatedAt"] as? Int).flatMap({ Date(timeIntervalSince1970: TimeInterval($0)) })
        
        return TodoItem(id: id, text: text, importance: importance, deadline: deadline, isDone: isDone, createdAt: createdAt, updatedAt: updatedAt)
    }
    
    var json: Any {
        var jsonDict = [String: Any]()
        
        jsonDict["id"] = id
        jsonDict["text"] = text
        
        switch importance {
        case .low, .important:
            jsonDict["importance"] = importance.rawValue
        case .normal:
            break
        }
        
        if let deadline = deadline {
            jsonDict["deadline"] = Int(deadline.timeIntervalSince1970)
        }
        
        jsonDict["isDone"] = isDone
        jsonDict["createdAt"] = Int(createdAt.timeIntervalSince1970)
        
        if let updatedAt = updatedAt {
            jsonDict["updatedAt"] = Int(updatedAt.timeIntervalSince1970)
        }
        
        return jsonDict
    }
}

