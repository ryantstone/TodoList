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

    // MARK: - Single Records
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

    public func fetchRecord(name: String,
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

    public func fetchAll<T: Serializable>(type: T.Type,
                         success: @escaping ([T]) -> (),
                         failure: @escaping (Error) -> ()) {

        let predicate = CKQuery(recordType: T.ckName, predicate: NSPredicate(value: true))
        query(with: predicate, success: { (records) in
            success(records.compactMap {
                do      { return try T.deserialize(record: $0, type: T.self) }
                catch   {
                    failure(error)
                    return nil
                }
            })
        }, failure: {(error) in
            failure(error)
        })
    }

    public func query(with query: CKQuery,
                      success: @escaping ([CKRecord]) -> (),
                      failure: @escaping(Error) -> ()) {
        privateDb.perform(query, inZoneWith: nil) { (records, error) in
            guard let records = records, error == nil else {
                failure(error!)
                return
            }
            success(records)
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

    // MARK: - Multiple Records
    public func subscribeToZone() {
        let sub = CKRecordZoneSubscription(zoneID: zone.zoneID)
        privateDb.save(sub) { (subscription, error) in
            print(subscription)
        }
    }

    func fetchZone(success: @escaping (CKRecordZone) -> (),
                   failure: @escaping (Error) -> ()) {

//        privateDb.fetch(withRecordZoneID: zone.zoneID) { (zone, error) in
//            guard let zone = zone, error == nil else {
//                failure(error!)
//                return
//            }
//            success(zone)
//        }

    }

    // MARK: - Utilities
    public func blankRecord<T: Serializable>(type: T.Type) -> CKRecord {
        return CKRecord(recordType: T.ckName, zoneID: zone.zoneID)
    }
}
