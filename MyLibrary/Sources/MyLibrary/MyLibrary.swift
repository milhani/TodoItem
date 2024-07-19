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
    
    private var todoItems: [String: T]
    private var isDirty = false
    private let filename: String
    private let fileFormat: Format
    
    
    public init(filename: String, fileFormat: Format) {
        self.filename = filename
        self.todoItems = [:]
        self.fileFormat = fileFormat
        try? load(from: filename, format: fileFormat)
    }

    
    public func add(_ item: T) {
        todoItems[item.id] = item
        try? save(to: filename, format: fileFormat)
    }
    
    public func remove(_ id: String) {
        guard todoItems[id] != nil else { return }
        todoItems.removeValue(forKey: id)
        try? save(to: filename, format: fileFormat)
    }
    
    public func setDirty(_ isDirty: Bool) {
        self.isDirty = isDirty
    }
    
    public func getIsDirty() -> Bool {
        return self.isDirty
    }
    
    public func save(to file: String, format: Format) throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            throw FileCacheErrors.cannotFindDocumentDirectory
        }
        
        let path = documentDirectory.appendingPathComponent(file)
        
        do {
            switch format {
            case .json:
                let serializedItems = todoItems.map { _, item in item.json }
                let data = try JSONSerialization.data(withJSONObject: serializedItems, options: [])
                try data.write(to: path)
            case .csv:
                //var data = TodoItem.csvHeadLine
                var data = todoItems.map { _, item in item.csv }.joined(separator: "\n")
                try data.write(to: path, atomically: true, encoding: .utf8)

            }
        } catch {
            throw FileCacheErrors.cannotSaveData
        }
    }
    
    public func load(from file: String, format: Format) throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            throw FileCacheErrors.cannotFindDocumentDirectory
        }
        
        let path = documentDirectory.appendingPathComponent(file)

        do {
            switch format {
            case .json:
                let data = try Data(contentsOf: path)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                guard let json = json as? [Any] else { throw FileCacheErrors.incorrectData }
                let newItems = json.compactMap { T.parse(json: $0) }
                self.todoItems = newItems.reduce(into: [String: T]()) { newArray, item in
                    newArray[item.id] = item
                }
            case .csv:
                var data = try String(contentsOf: path).components(separatedBy: "\n")
                guard !data.isEmpty else { throw FileCacheErrors.incorrectData }
                data.removeFirst()
                let newItems = data.compactMap { T.parse(csv: $0) }
                self.todoItems = newItems.reduce(into: [String: T]()) { newArray, item in
                    newArray[item.id] = item
                }
            }
        } catch {
            throw FileCacheErrors.cannotLoadData
        }
    }
}
