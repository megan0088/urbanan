//
//  FoundReport.swift
//  urbanan
//

import Foundation
import CloudKit

struct FoundReport: Identifiable {
    var id: CKRecord.ID
    var itemRef: CKRecord.Reference
    var finderRef: CKRecord.Reference
    var reportDescription: String
    var photoURL: URL?
    var foundDate: Date
    var foundLatitude: Double?
    var foundLongitude: Double?
    var status: ReportStatus

    enum ReportStatus: String {
        case pending   = "Pending"
        case confirmed = "Confirmed"
    }

    init(record: CKRecord) {
        id                = record.recordID
        itemRef           = record["itemRef"] as! CKRecord.Reference
        finderRef         = record["finderRef"] as! CKRecord.Reference
        reportDescription = record["description"] as? String ?? ""
        foundDate         = record["foundDate"] as? Date ?? Date()
        foundLatitude     = record["foundLatitude"] as? Double
        foundLongitude    = record["foundLongitude"] as? Double
        status            = ReportStatus(rawValue: record["status"] as? String ?? "") ?? .pending
        if let asset = record["photo"] as? CKAsset { photoURL = asset.fileURL }
    }
}
