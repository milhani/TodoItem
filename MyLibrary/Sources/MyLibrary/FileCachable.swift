import Foundation


public protocol FileCachable {
    var id: String { get }
    var json: Any { get }
    var csv: String { get }
    var csvHeadLine: String { get }
    
    static func parse(json: Any) -> Self?
    static func parse(csv: String) -> Self?
}
