import Foundation
import CloudKit

class CloudKitService {
    let defaultContainer = CKContainer.default()
    let publicDb: CKDatabase
    let privateDb: CKDatabase
    
    init() {
        publicDb    = defaultContainer.publicCloudDatabase
        privateDb   = defaultContainer.privateCloudDatabase
    }
    
    public func save(record: CKRecord,
                     success: @escaping (CKRecord) -> (),
                     failure: @escaping (Error) -> ()) {
        
        privateDb.save(record) { (record, error) in
            guard let record = record, error == nil else {
                failure(error!)
                return
            }
            success(record)
        }
    }
}
