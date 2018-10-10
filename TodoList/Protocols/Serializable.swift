import Foundation
import CloudKit

protocol Serializable {
    func serialize()
    func buildRecord() -> CKRecord
}
