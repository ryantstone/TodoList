import Foundation
import CloudKit

struct Todos: Codable {
    var items: [Item] {
        didSet { self.save() }
    }

    init(items: [Item]) {
        self.items = items
        loadRemote()
    }
}
//NOTE: UserDefaults is a temporary solution
extension Todos {
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "todoList")
        }
    }

    static func load() -> Todos {
        if let savedItems = UserDefaults.standard.object(forKey: "todoList") as? Data {
            if let loadedItems = try? JSONDecoder().decode(Todos.self, from:savedItems) {
                return loadedItems
            }
        }
        return Todos(items: [])
    }
    
    func loadRemote() {
        let cloudKitService = CloudKitService()
        let group = DispatchGroup()
        items.forEach { (item) in
            group.enter()
            guard let name = item.recordName else { return }
            cloudKitService.getRecord(name: name, success: { (record) in
                print(record)
                group.leave()
            }, failure: { (error) in
                print(error)
                group.leave()
            })
        }
    }
    
    func getCompletedItems(success: @escaping ([CKRecord]) -> ()) {
        let query        = CKQuery(recordType: "item", predicate: isCompletedPredicate())
        let cloudKitService = CloudKitService()
        cloudKitService.query(with: query, success: { (records) in
            print(records)
            success(records)
        }, failure: { (error) in
            print(error)
        })
    }
    
    func subscribeToCompletedItems() {
        let cloudKitService = CloudKitService()
        cloudKitService.subscribe(with: isCompletedPredicate(), of: "item", success: { (record) in
            print(record)
        }) { (error) in
            print(error)
        }
    }
    
    func isCompletedPredicate() -> NSPredicate {
        return NSPredicate(format: "isComplete = 0")
    }
}
