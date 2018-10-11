import Foundation
import CloudKit

class Item {
    let title: String
    var record: CKRecord?
    var recordName: String?
    var isComplete: Bool {
        didSet { serialize() }
    }

    init(title: String, isComplete: Bool = false, record: CKRecord?) {
        self.title      = title
        self.isComplete = isComplete
        self.record     = record
        serialize()
    }
    
    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        recordName      = try container.decode(String.self, forKey: .recordName)
        title           = try container.decode(String.self, forKey: .title)
        isComplete      = try container.decode(Bool.self, forKey: .isComplete)
    }
}

// MARK: - Serialization
extension Item: Serializable {
    func serialize() {
        CloudKitService.init().save(record: buildRecord(), success: { (record) in
                self.record = record
        }, failure: {(error) in
            print(error)
        })
    }

    func buildRecord() -> CKRecord {
        let record = self.record == nil ? CKRecord(recordType: "item") : self.record!
        recordName              = record.recordID.recordName
        record["isComplete"]    = isComplete ? 0 : 1
        record["title"]         = title
        return record
    }
}

// MARK: - Codable
extension Item: Codable {
    private enum CodingKeys: String, CodingKey {
        case title,
             isComplete,
             recordName
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(isComplete, forKey: .isComplete)
        if let recordName = self.recordName {
            try container.encode(recordName, forKey: .recordName)
        }
    }
}
