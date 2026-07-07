//
//  FoundReport.swift
//  SharedCore
//

import Foundation

/// Pure domain model — no CloudKit types leak in here.
/// `FoundReportMapper` is the only place that converts to/from `CKRecord`.
struct FoundReport: Identifiable, Equatable {
    let id: UUID
    let itemID: UUID
    var station: String
    var note: String?
    var photoData: Data?
    var status: ReportStatus
    var isRead: Bool
    let reportedAt: Date
    var claimedAt: Date?
}
