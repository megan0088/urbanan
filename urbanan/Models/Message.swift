//
//  Message.swift
//  urbanan
//

import Foundation
import CloudKit

struct Message: Identifiable {
    var id: CKRecord.ID
    var foundReportRef: CKRecord.Reference
    var senderID: String
    var content: String
    var timestamp: Date
    var isRead: Bool

    init(record: CKRecord) {
        id             = record.recordID
        foundReportRef = record["foundReportRef"] as! CKRecord.Reference
        senderID       = record["senderID"] as? String ?? ""
        content        = record["content"] as? String ?? ""
        timestamp      = record["timestamp"] as? Date ?? Date()
        isRead         = (record["isRead"] as? Int ?? 0) == 1
    }

    func toRecord() -> CKRecord {
        let record = CKRecord(recordType: "Message", recordID: id)
        record["foundReportRef"] = foundReportRef
        record["senderID"]       = senderID
        record["content"]        = content
        record["timestamp"]      = timestamp
        record["isRead"]         = isRead ? 1 : 0
        return record
    }
}
