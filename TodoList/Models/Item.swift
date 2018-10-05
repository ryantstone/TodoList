import Foundation
import CloudKit

class Item: Codable {
    let title: String
    var recordId: CKRecordID?
    var isComplete: Bool
    var record: CKRecord
    
    init(title: String, isComplete: Bool = false, record: CKRecord?) {
        self.title = title
        self.isComplete = isComplete
        if let record = record {
            self.record = record
        } else {
            self.record = CKRecord(recordType: "item")
            self.record["title"] = self.title
            self.record["isComplete"] = self.isComplete
        }
    }
    
    public func save() {
        CloudKitService.init().save(record: record) { (record) in
            self.record = record
            self.recordId = record.recordID
        }
    }
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case title
        case isComplete
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        isComplete = try container.decode(Bool.self, forKey: .isComplete)
        
        self.record = CKRecord(recordType: "item")
        self.record["title"] = self.title
        self.record["isComplete"] = self.isComplete
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(isComplete, forKey: .isComplete)
    }
}
