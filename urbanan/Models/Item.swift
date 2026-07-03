//
//  Item.swift
//  urbanan
//

import Foundation
import CloudKit

struct Item: Identifiable {
    var id: CKRecord.ID
    var name: String
    var itemDescription: String
    var category: ItemCategory
    var status: ItemStatus
    var lostDate: Date
    var photoURL: URL?
    var iconName: String
    var iconColor: String
    var latitude: Double?
    var longitude: Double?
    var ownerID: String

    enum ItemStatus: String, CaseIterable {
        case lost    = "Lost"
        case found   = "Found"
        case claimed = "Claimed"
    }

    enum ItemCategory: String, CaseIterable {
        case bag     = "Bag"
        case wallet  = "Wallet"
        case phone   = "Phone"
        case keys    = "Keys"
        case jewelry = "Jewelry"
        case other   = "Other"
    }

    // Membuat item baru (sebelum disimpan ke CloudKit)
    init(name: String, description: String, category: ItemCategory,
         lostDate: Date, iconName: String, iconColor: String, ownerID: String) {
        self.id              = CKRecord.ID()
        self.name            = name
        self.itemDescription = description
        self.category        = category
        self.status          = .lost
        self.lostDate        = lostDate
        self.iconName        = iconName
        self.iconColor       = iconColor
        self.ownerID         = ownerID
    }

    // Membaca data dari CloudKit record
    init(record: CKRecord) {
        id              = record.recordID
        name            = record["name"] as? String ?? ""
        itemDescription = record["description"] as? String ?? ""
        category        = ItemCategory(rawValue: record["category"] as? String ?? "") ?? .other
        status          = ItemStatus(rawValue: record["status"] as? String ?? "") ?? .lost
        lostDate        = record["lostDate"] as? Date ?? Date()
        iconName        = record["iconName"] as? String ?? "questionmark.circle"
        iconColor       = record["iconColor"] as? String ?? "blue"
        latitude        = record["latitude"] as? Double
        longitude       = record["longitude"] as? Double
        ownerID         = record["ownerID"] as? String ?? ""
        if let asset = record["photo"] as? CKAsset { photoURL = asset.fileURL }
    }

    // Mengubah item menjadi CKRecord untuk disimpan
    func toRecord() -> CKRecord {
        let record = CKRecord(recordType: "Item", recordID: id)
        record["name"]        = name
        record["description"] = itemDescription
        record["category"]    = category.rawValue
        record["status"]      = status.rawValue
        record["lostDate"]    = lostDate
        record["iconName"]    = iconName
        record["iconColor"]   = iconColor
        record["latitude"]    = latitude
        record["longitude"]   = longitude
        record["ownerID"]     = ownerID
        return record
    }
}
