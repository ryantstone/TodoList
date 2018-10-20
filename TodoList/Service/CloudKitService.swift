import Foundation
import CloudKit

class CloudKitService {
    let defaultContainer = CKContainer.default()
    let publicDb: CKDatabase
    let privateDb: CKDatabase
    let zone: CKRecordZone
    
    
    init() {
        publicDb    = defaultContainer.publicCloudDatabase
        privateDb   = defaultContainer.privateCloudDatabase
        zone        = CKRecordZone(zoneName: "main")
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
    
    public func subscribe(with predicate: NSPredicate,
                          of recordType: String,
                          success: (CKRecord) -> (),
                          failure: (Error) -> ()) {
        
        let querySubscription   = CKQuerySubscription(recordType: recordType, predicate: predicate, options: .firesOnRecordUpdate)
        let notification        = CKNotificationInfo()
        notification.alertBody  = "RECORD UPDATED"
        notification.soundName  = "default"
        notification.shouldBadge = true
        
        querySubscription.notificationInfo = notification
        
        privateDb.save(querySubscription) { (subscription, error) in
            print(subscription)
        }
    }
    
    public func subscribeToZone() {
        let sub = CKRecordZoneSubscription(zoneID: zone.zoneID)
        privateDb.save(sub) { (subscription, error) in
            print(subscription)
        }
    }
    
    public func blankRecord<T: CKNamed>(type: T) -> CKRecord {
        return CKRecord(recordType: type.ckName, zoneID: zone.zoneID)
    }
}
