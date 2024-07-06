import Foundation


struct Category: Identifiable, Hashable {
    let name: String
    let color: String
    
    var id: Self { self }
    
    static var defaultCategories: [Category] {
        var lst = [Category]()
        lst.append(Category(name: "Другое", color: "#FFFFFF"))
        lst.append(Category(name: "Работа", color: "#FF0000"))
        lst.append(Category(name: "Учеба", color: "#0000FF"))
        lst.append(Category(name: "Хобби", color: "#008000"))
        return lst
    }

}
