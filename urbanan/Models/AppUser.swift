//
//  AppUser.swift
//  urbanan
//

import Foundation
import CloudKit

struct AppUser: Identifiable {
    var id: CKRecord.ID
    var name: String
    var email: String
    var profilePhotoURL: URL?

    init(record: CKRecord) {
        id              = record.recordID
        name            = record["name"] as? String ?? ""
        email           = record["email"] as? String ?? ""
        if let asset = record["profilePhoto"] as? CKAsset { profilePhotoURL = asset.fileURL }
    }

    func toRecord() -> CKRecord {
        let record = CKRecord(recordType: "UserProfile", recordID: id)
        record["name"]  = name
        record["email"] = email
        return record
    }
}
