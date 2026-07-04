//
//  FoundReportMapper.swift
//  SharedCore
//

import Foundation
import CloudKit

/// Pure `CKRecord` ↔ `FoundReport` conversion — the only place `FoundReport`
/// is allowed to touch a CloudKit type.
enum FoundReportMapper {
    static func toFoundReport(record: CKRecord) throws -> FoundReport {
        guard record.recordType == RecordSchema.FoundReport.recordType else {
            throw TaggoError.invalidRecordType(expected: RecordSchema.FoundReport.recordType, actual: record.recordType)
        }
        guard let id = UUID(uuidString: record.recordID.recordName) else {
            throw TaggoError.invalidFieldValue("recordID")
        }
        guard let itemIDString = record[RecordSchema.FoundReport.Field.itemID] as? String,
              let itemID = UUID(uuidString: itemIDString) else {
            throw TaggoError.missingField(RecordSchema.FoundReport.Field.itemID)
        }
        guard let station = record[RecordSchema.FoundReport.Field.station] as? String else {
            throw TaggoError.missingField(RecordSchema.FoundReport.Field.station)
        }
        guard let statusRaw = record[RecordSchema.FoundReport.Field.status] as? String,
              let status = ReportStatus(rawValue: statusRaw) else {
            throw TaggoError.missingField(RecordSchema.FoundReport.Field.status)
        }
        guard let isRead = record[RecordSchema.FoundReport.Field.isRead] as? Bool else {
            throw TaggoError.missingField(RecordSchema.FoundReport.Field.isRead)
        }
        guard let reportedAt = record[RecordSchema.FoundReport.Field.reportedAt] as? Date else {
            throw TaggoError.missingField(RecordSchema.FoundReport.Field.reportedAt)
        }

        let finderID = (record[RecordSchema.FoundReport.Field.finderID] as? String).flatMap(UUID.init(uuidString:))
        let note = record[RecordSchema.FoundReport.Field.note] as? String
        let claimedAt = record[RecordSchema.FoundReport.Field.claimedAt] as? Date

        var photoData: Data?
        if let asset = record[RecordSchema.FoundReport.Field.photoAsset] as? CKAsset, let fileURL = asset.fileURL {
            photoData = try? Data(contentsOf: fileURL)
        }

        return FoundReport(
            id: id,
            itemID: itemID,
            finderID: finderID,
            station: station,
            note: note,
            photoData: photoData,
            status: status,
            isRead: isRead,
            reportedAt: reportedAt,
            claimedAt: claimedAt
        )
    }

    static func toRecord(report: FoundReport, existingRecord: CKRecord? = nil) -> CKRecord {
        let record = existingRecord ?? CKRecord(
            recordType: RecordSchema.FoundReport.recordType,
            recordID: CKRecord.ID(recordName: report.id.uuidString)
        )

        record[RecordSchema.FoundReport.Field.itemID] = report.itemID.uuidString
        record[RecordSchema.FoundReport.Field.finderID] = report.finderID?.uuidString
        record[RecordSchema.FoundReport.Field.station] = report.station
        record[RecordSchema.FoundReport.Field.note] = report.note
        record[RecordSchema.FoundReport.Field.status] = report.status.rawValue
        record[RecordSchema.FoundReport.Field.isRead] = report.isRead
        record[RecordSchema.FoundReport.Field.reportedAt] = report.reportedAt
        record[RecordSchema.FoundReport.Field.claimedAt] = report.claimedAt

        if let photoData = report.photoData, let asset = try? Self.makeAsset(from: photoData) {
            record[RecordSchema.FoundReport.Field.photoAsset] = asset
        }

        return record
    }

    /// `CKAsset` requires a file on disk — writes the data to a temp file so it can be attached.
    private static func makeAsset(from data: Data) throws -> CKAsset {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try data.write(to: url)
        return CKAsset(fileURL: url)
    }
}
