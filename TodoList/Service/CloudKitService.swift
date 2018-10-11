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
    
    public func getRecord(name: String,
                          success: @escaping (CKRecord) -> (),
                          failure: @escaping (Error) -> ()) {
        let record = CKRecordID(recordName: name)
        privateDb.fetch(withRecordID: record) { (record, error) in
            guard let record = record, error == nil else {
                failure(error!)
                return
            }
            success(record)
        }
    }
    public func query(with query: CKQuery,
                      success: @escaping ([CKRecord]) -> (),
                      failure: @escaping(Error) -> ()) {
        privateDb.perform(query, inZoneWith: nil) { (records, error) in
            guard let records = records, error == nil else {
                print(error!)
                return
            }
            print(records)
        }
    }
}
