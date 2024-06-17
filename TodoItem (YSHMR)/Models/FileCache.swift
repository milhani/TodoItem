//
//  FileCache.swift
//  TodoItem (YSHMR)
//
//  Created by Людмила Ханина on 17.06.2024.
//

import Foundation


enum FileCacheErrors: Error {
    case cannotFindDocumentDirectory
    case incorrectData
}


final class FileCache {
    private(set) var items: [String: TodoItem] = [:]
    
    func add(_ item: TodoItem) {
        items[item.id] = item
    }
    
    func remove(_ id: String) {
        guard items[id] != nil else { return }
        items.removeValue(forKey: id)
    }
    
    func save(to file: String) throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            throw FileCacheErrors.cannotFindDocumentDirectory
        }
        
        let path = documentDirectory.appendingPathComponent(file)
        let serializedItems = items.map { _, item in item.json }
        let data = try JSONSerialization.data(withJSONObject: serializedItems, options: [])
        try data.write(to: path)
    }
    
    func load(from file: String) throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            throw FileCacheErrors.cannotFindDocumentDirectory
        }
        
        let path = documentDirectory.appendingPathComponent(file)
        let data = try Data(contentsOf: path)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let json = json as? [Any] else { throw FileCacheErrors.incorrectData }
        let newItems = json.compactMap { TodoItem.parse(json: $0) }
        self.items = newItems.reduce(into: [String: TodoItem]()) { newArray, item in
            newArray[item.id] = item
        }
    }
}
