import Foundation
import CloudKit

protocol Serializable {
    static var ckName: String {
        get
    }

    func serialize()
    func buildRecord() -> CKRecord
    static func deserialize<T: Serializable>(record: CKRecord, type: T.Type) throws -> T
}

enum SerializationError: Error {
    case invalidValues
}
