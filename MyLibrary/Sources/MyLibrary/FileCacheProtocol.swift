import Foundation
import TodoItem__YSHMR_


public protocol FileCacheProtocol {
    static func add(_ item: TodoItem)
    static func remove(_ id: String)

    static func save(to file: String, format: Format) throws
    static func load(from file: String, format: Format) throws
    
    static func setDirty(_ isDirty: Bool)
    static func getIsDirty() -> Bool
}
