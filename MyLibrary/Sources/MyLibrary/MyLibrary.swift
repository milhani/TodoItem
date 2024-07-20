import Foundation


public enum FileCacheErrors: Error {
    case cannotFindDocumentDirectory
    case incorrectData
    case cannotSaveData
    case cannotLoadData
}

public enum Format {
    case json
    case csv
}


public final class FileCache<T: FileCachable>  {
    
    public var todoItems: [String: T]
    var isDirty = false
    private let filename: String
    private let fileFormat: Format
    
    
    public init(filename: String, fileFormat: Format) {
        self.filename = filename
        self.todoItems = [:]
        self.fileFormat = fileFormat
        _ = load()
    }

    
    public func add(_ item: T) {
        todoItems[item.id] = item
        save()
    }
    
    public func remove(_ id: String) {
        guard todoItems[id] != nil else { return }
        todoItems.removeValue(forKey: id)
        save()
    }
    
    public func setDirty(_ isDirty: Bool) {
        self.isDirty = isDirty
    }
    
    public func getIsDirty() -> Bool {
        return self.isDirty
    }
    
    public func save() {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            return
            //throw FileCacheErrors.cannotFindDocumentDirectory
        }
        
        let path = documentDirectory.appendingPathComponent(filename)
        
        do {
            switch fileFormat {
            case .json:
                let serializedItems = todoItems.map { _, item in item.json }
                let data = try JSONSerialization.data(withJSONObject: serializedItems, options: [])
                try data.write(to: path)
            case .csv:
                //var data = TodoItem.csvHeadLine
                let data = todoItems.map { _, item in item.csv }.joined(separator: "\n")
                try data.write(to: path, atomically: true, encoding: .utf8)

            }
        } catch {
            print("FAILED SAVE")
            //throw FileCacheErrors.cannotSaveData
        }
    }
    
    public func load() -> [T]? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            //throw FileCacheErrors.cannotFindDocumentDirectory
            return nil
        }
        
        let path = documentDirectory.appendingPathComponent(filename)

        do {
            switch fileFormat {
            case .json:
                let data = try Data(contentsOf: path)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                guard let json = json as? [Any] else { throw FileCacheErrors.incorrectData }
                let newItems = json.compactMap { T.parse(json: $0) }
                self.todoItems = newItems.reduce(into: [String: T]()) { newArray, item in
                    newArray[item.id] = item
                }
                return newItems
            case .csv:
                var data = try String(contentsOf: path).components(separatedBy: "\n")
                guard !data.isEmpty else { throw FileCacheErrors.incorrectData }
                data.removeFirst()
                let newItems = data.compactMap { T.parse(csv: $0) }
                self.todoItems = newItems.reduce(into: [String: T]()) { newArray, item in
                    newArray[item.id] = item
                }
                return newItems
            }
        } catch {
            //throw FileCacheErrors.cannotLoadData
            save()
        }
        return []
    }
}
