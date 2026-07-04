//
//  RecordSchema.swift
//  SharedCore
//

import Foundation

/// Central catalogue of CloudKit record type names and field keys.
/// `ItemMapper`/`FoundReportMapper` are the only places these constants
/// should be consumed from, keeping raw CKRecord key strings out of the rest of the app.
enum RecordSchema {
    enum Item {
        static let recordType = "Item"

        enum Field {
            static let ownerID = "ownerID"
            static let name = "name"
            static let category = "category"
            static let color = "color"
//            static let brand = "brand"
            static let description = "description"
            static let imageAsset = "imageAsset"
//            static let status = "status"
            static let createdAt = "createdAt"
            static let updatedAt = "updatedAt"
        }
    }

    enum FoundReport {
        static let recordType = "FoundReport"

        enum Field {
            static let itemID = "itemID"
            static let finderID = "finderID"
            static let station = "station"
            static let note = "note"
            static let photoAsset = "photoAsset"
            static let status = "status"
            static let isRead = "isRead"
            static let reportedAt = "reportedAt"
            static let claimedAt = "claimedAt"
        }
    }
}
