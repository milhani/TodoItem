import XCTest
@testable import TodoItem__YSHMR_


fileprivate enum MockConstants {
    static let fullCorrectJSON: [String: Any] = [
        "id": "kfdjs3443kjd",
        "text": "Unfortunately, she had not anticipated that others may be looking upon her from other angles, and now they were stealthily descending toward her hiding spot.",
        "importance": "important",
        "deadline": 82736456,
        "isDone": true,
        "createdAt": 27362363,
        "updatedAt": 27362863
    ]
    static let createdAtInvalidJSON: [String: Any] = [
        "id": "kfdjs3443kjd",
        "text": "Unfortunately, she had not anticipated that others may be looking upon her from other angles, and now they were stealthily descending toward her hiding spot.",
        "importance": "important",
        "deadline": 82736456,
        "isDone": true,
        "createdAt": "",
        "updatedAt": 27362863
    ]
    static let minimumValidJSON: [String: Any] = [
        "id": "kfdjs3443kjd",
        "text": "Unfortunately, she had not anticipated that others may be looking upon her from other angles, and now they were stealthily descending toward her hiding spot.",
        "isDone": true,
        "createdAt": 1686664070,
    ]
    static let oneDefindedTimeJSON: [String: Any] = [
        "id": "kfdjs3443kjd",
        "text": "Unfortunately, she had not anticipated that others may be looking upon her from other angles, and now they were stealthily descending toward her hiding spot.",
        "importance": "important",
        "deadline": 82736456,
        "isDone": false,
        "createdAt": 1686664070,
    ]
    static let fullCorrectCSV = """
    id,text,importance,deadline,isDone,createdAt,updatedAt
    1,Unfortunately, she had not anticipated that others may be looking upon her from other angles, and now they were stealthily descending toward her hiding spot.,important,2024-06-15T23:10:23Z,true,2024-06-15T23:10:23Z,2024-06-15T23:10:23Z
    """
    static let createdAtInvalidCSV = """
    id,text,importance,deadline,isDone,createdAt,updatedAt
    1,Unfortunately, she had not anticipated that others may be looking upon her from other angles, and now they were stealthily descending toward her hiding spot.,important,2024-06-15T23:10:23Z,true,,2024-06-15T23:10:23Z
    """
    static let minimumValidCSV = """
    id,text,importance,deadline,isDone,createdAt,updatedAt
    1,Unfortunately, she had not anticipated that others may be looking upon her from other angles, and now they were stealthily descending toward her hiding spot.,,,true,2024-06-15T23:10:23Z,2024-06-15T23:15:23Z,
    """
    static let withoutOptionDatesCSV = """
    id,text,importance,deadline,isDone,createdAt,updatedAt
    1,Unfortunately, she had not anticipated that others may be looking upon her from other angles, and now they were stealthily descending toward her hiding spot.,,,true,2024-06-15T23:10:23Z,
    """
}


final class TodoItem__YSHMR_Tests: XCTestCase {
    
    //Проверка, что ID сгенерирован
    func testA() {
        let item = TodoItem(id: nil, text: "lala", importance: .normal, deadline: nil, isDone: true, createdAt: Date(), updatedAt: nil)
        
        XCTAssertNotNil(UUID(uuidString: item.id))
    }
    
    //Проверка необязательных временных полей и isDone
    func testB() {
        for _ in 0..<10 {
            let isDone = Bool.random()
            var deadline: Date? = nil
            let createdAt = Date()
            var updateAt: Date? = nil
            
            if isDone {
                deadline = Date() + TimeInterval.random(in: 0..<100)
                updateAt = Date() + TimeInterval.random(in: 0..<100)
            }
            let item = TodoItem(id: "1", text: "lala", importance: .normal, deadline: deadline, isDone: isDone, createdAt: createdAt, updatedAt: updateAt)
            
            XCTAssertEqual(item.isDone, isDone)
            XCTAssertEqual(item.deadline, deadline)
            XCTAssertEqual(item.createdAt, createdAt)
            XCTAssertEqual(item.updatedAt, updateAt)
        }
    }
    
    //Проверка, что создается json с минимальным набором обязательных элементов
    func testC() {
        let item = TodoItem(id: "1", text: "lala", importance: .normal, deadline: nil, isDone: true, createdAt: Date(), updatedAt: nil)
        let json = item.json
        XCTAssertNotNil(json)
        XCTAssertNotNil(json as? [String: Any])
        XCTAssertNoThrow(try JSONSerialization.data(withJSONObject: json))
    }
    
    //Проверка, что обычная важность задачи не записывается в json
    func testD() {
        for _ in 0..<10 {
            let array: [Importance] = [.low, .normal, .important]
            let importance = array.randomElement()!
            
            let item = TodoItem(id: "1", text: "lala", importance: importance, deadline: nil, isDone: true, createdAt: Date(), updatedAt: nil)
            
            let json = item.json as? [String: Any]
            guard let containsImportance = json?.contains(where: { $0.key == Keys.importance.rawValue})
            else {
                XCTAssertNotNil(json)
                return
            }
            XCTAssertEqual(containsImportance, importance != .normal)
        }
    }
    
    //Проверка, что необязательные временные поля не записываются в json в случае nil
    func testE() {
        for i in 0..<10 {
            var deadline: Date? = nil
            if i % 2 == 0 {
                deadline = Date() + TimeInterval.random(in: 0..<100)
            }
            
            var updateAt: Date? = nil
            if i % 2 != 0 {
                updateAt = Date() + TimeInterval.random(in: 0..<100)
            }
            let item = TodoItem(id: "1", text: "lala", importance: .low, deadline: deadline, isDone: true, createdAt: Date(), updatedAt: updateAt)
            
            let json = item.json as? [String: Any]
            
            let containsDeadline = json?.contains(where: { $0.key == Keys.deadline.rawValue })
            XCTAssertEqual(containsDeadline, deadline != nil)
            
            let containsUpdateAt = json?.contains(where: { $0.key == Keys.updatedAt.rawValue })
            XCTAssertEqual(containsUpdateAt, updateAt != nil)
        }
    }
    
    //Проверка полного, корректного json
    func testF() {
        guard let item = TodoItem.parse(json: MockConstants.fullCorrectJSON)
        else {
            XCTAssertNotNil(TodoItem.parse(json: MockConstants.fullCorrectJSON))
            return
        }
        
        XCTAssertTrue(!item.id.isEmpty)
        XCTAssertNotEqual(item.importance, Importance.normal)
        XCTAssertNotNil(item.deadline)
        XCTAssertNotNil(item.updatedAt)
    }
    
    //Проверка json с некорректным временем создания item
    func testG() {
        let item = TodoItem.parse(json: MockConstants.createdAtInvalidJSON)
        XCTAssertNil(item)
    }
    
    //Проверка, что создается TodoItem с минимальным набором обязательных элементов в json
    func testH() {
        guard let item = TodoItem.parse(json: MockConstants.minimumValidJSON)
        else {
            XCTAssertNotNil(TodoItem.parse(json: MockConstants.minimumValidJSON))
            return
        }
        XCTAssertNil(item.deadline)
        XCTAssertEqual(item.importance, Importance.normal)
        XCTAssertNil(item.updatedAt)
    }
    
    //Проверка, что одно необязательное поле заполнено, а второе нет
    func testI() {
        guard let item = TodoItem.parse(json: MockConstants.oneDefindedTimeJSON)
        else {
            XCTAssertNotNil(TodoItem.parse(json: MockConstants.oneDefindedTimeJSON))
            return
        }
        XCTAssertNotNil(item.deadline)
        XCTAssertNil(item.updatedAt)
    }
    
    //Проверка, что csv вычисляется правильно при всех данных
    func testJ() {
        let item = TodoItem(id: "1", text: "lala", importance: .low, deadline: Date(timeIntervalSince1970: 1686664072), isDone: true, createdAt: Date(timeIntervalSince1970: 1686684070), updatedAt: Date(timeIntervalSince1970: 1686684072))
        let string = "1,lala,low,1686664072,true,1686684070,1686684072"
        let csv = item.csv
        XCTAssertEqual(string, csv)
    }
    
    //Проверка, что в csv нет обычной важности
    func testK() {
        let item = TodoItem(id: "1", text: "lala", importance: .normal, deadline: Date(timeIntervalSince1970: 1686664072), isDone: true, createdAt: Date(timeIntervalSince1970: 1686684070), updatedAt: Date(timeIntervalSince1970: 1686684072))
        let string = "1,lala,,1686664072,true,1686684070,1686684072"
        let csv = item.csv
        XCTAssertEqual(string, csv)
    }
    
    //Проверка, что необязательные временные поля не записываются в csv в случае nil
    func testL() {
        let item = TodoItem(id: "1", text: "lala,bebe", importance: .normal, deadline: nil, isDone: true, createdAt: Date(timeIntervalSince1970: 1686684070), updatedAt: nil)
        let string = "1,lala,bebe,,true,1686684070,"
        let csv = item.csv
        XCTAssertEqual(string, csv)
    }
    
    //Проверка полного, корректного csv
    func testM() {
        guard let item = TodoItem.parse(csv: MockConstants.fullCorrectCSV)
        else {
            XCTAssertNotNil(TodoItem.parse(csv: MockConstants.fullCorrectCSV))
            return
        }
        XCTAssertFalse(item.id.isEmpty)
        XCTAssertNotNil(item.deadline)
        XCTAssertNotNil(item.updatedAt)
        XCTAssertNotEqual(item.importance, Importance.normal)
        
    }
    
    //Проверка csv с некорректным временем создания item
    func testN() {
        let item = TodoItem.parse(csv: MockConstants.createdAtInvalidCSV)
        XCTAssertNil(item)
    }
    
    //Проверка, что создается TodoItem с минимальным набором обязательных элементов в csv
    func testP() {
        guard let item = TodoItem.parse(csv: MockConstants.minimumValidCSV)
        else {
            XCTAssertNotNil(TodoItem.parse(csv: MockConstants.minimumValidCSV))
            return
        }
        XCTAssertEqual(item.importance, Importance.normal)
        
    }
    
    //Проверка, что необязательные поля в csv записываются в TodoItem как nil
    func testQ() {
        guard let item = TodoItem.parse(csv: MockConstants.withoutOptionDatesCSV)
        else {
            XCTAssertNotNil(TodoItem.parse(csv: MockConstants.withoutOptionDatesCSV))
            return
        }
        XCTAssertNil(item.deadline)
        XCTAssertNil(item.updatedAt)
    }
}
