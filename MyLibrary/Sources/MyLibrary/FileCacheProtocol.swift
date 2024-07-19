import Foundation


public protocol FileCacheProtocol {
    associatedtype T: FileCachable
    
    static func add(_ item: T)
    static func remove(_ id: String)

    static func save(to file: String, format: Format) throws
    static func load(from file: String, format: Format) throws
    
    static func setDirty(_ isDirty: Bool)
    static func getIsDirty() -> Bool
}
