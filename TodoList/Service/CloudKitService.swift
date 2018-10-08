import Foundation
import CloudKit

class CloudKitService {
    let defaultContainer = CKContainer.default()
    let publicDb: CKDatabase
    let privateDb: CKDatabase
    
    init() {
        publicDb = defaultContainer.publicCloudDatabase
        privateDb = defaultContainer.privateCloudDatabase
    }
    
    public func save(record: CKRecord, completion: @escaping (CKRecord) -> ()) {
        privateDb.save(record) { (record, error) in
            guard let record = record else {
                print(error)
                return
            }
            completion(record)
        }
    }
    
    public func update() {
    }
}
