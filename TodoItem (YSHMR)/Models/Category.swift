import Foundation


struct Category: Identifiable, Hashable {
    let name: String
    let color: String
    
    var id: Self { self }
    
    static var defaultCategories: [Category] {
        var lst = [Category]()
        lst.append(Category(name: "Другое", color: "#FFFFFF"))
        lst.append(Category(name: "Работа", color: Colors.primaryRed.hex))
        lst.append(Category(name: "Учеба", color: Colors.primaryBlue.hex))
        lst.append(Category(name: "Хобби", color: Colors.primaryGreen.hex))
        return lst
    }

}
