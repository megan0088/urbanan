//
//  FoundReportMapperTests.swift
//  TaggoTests
//

import XCTest
import CloudKit

final class FoundReportMapperTests: XCTestCase {
    private func makeRecord(
        id: UUID = UUID(),
        itemID: UUID = UUID(),
        finderID: UUID? = UUID(),
        station: String = "Central Station",
        note: String? = "Found near the ticket gate",
        status: ReportStatus = .pending,
        isRead: Bool = false,
        reportedAt: Date = Date(timeIntervalSince1970: 0),
        claimedAt: Date? = nil
    ) -> CKRecord {
        let record = CKRecord(recordType: RecordSchema.FoundReport.recordType, recordID: CKRecord.ID(recordName: id.uuidString))
        record[RecordSchema.FoundReport.Field.itemID] = itemID.uuidString
        record[RecordSchema.FoundReport.Field.finderID] = finderID?.uuidString
        record[RecordSchema.FoundReport.Field.station] = station
        record[RecordSchema.FoundReport.Field.note] = note
        record[RecordSchema.FoundReport.Field.status] = status.rawValue
        record[RecordSchema.FoundReport.Field.isRead] = isRead
        record[RecordSchema.FoundReport.Field.reportedAt] = reportedAt
        record[RecordSchema.FoundReport.Field.claimedAt] = claimedAt
        return record
    }

    func test_toFoundReport_mapsAllFieldsFromRecord() throws {
        let id = UUID()
        let itemID = UUID()
        let finderID = UUID()
        let record = makeRecord(id: id, itemID: itemID, finderID: finderID)

        let report = try FoundReportMapper.toFoundReport(record: record)

        XCTAssertEqual(report.id, id)
        XCTAssertEqual(report.itemID, itemID)
        XCTAssertEqual(report.finderID, finderID)
        XCTAssertEqual(report.station, "Central Station")
        XCTAssertEqual(report.note, "Found near the ticket gate")
        XCTAssertEqual(report.status, .pending)
        XCTAssertFalse(report.isRead)
        XCTAssertEqual(report.reportedAt, Date(timeIntervalSince1970: 0))
        XCTAssertNil(report.claimedAt)
        XCTAssertNil(report.photoData)
    }

    func test_toFoundReport_allowsNilFinderIDForAnonymousAppClipReport() throws {
        let record = makeRecord(finderID: nil)

        let report = try FoundReportMapper.toFoundReport(record: record)

        XCTAssertNil(report.finderID)
    }

    func test_toFoundReport_throwsOnWrongRecordType() {
        let record = CKRecord(recordType: "SomethingElse", recordID: CKRecord.ID(recordName: UUID().uuidString))

        XCTAssertThrowsError(try FoundReportMapper.toFoundReport(record: record)) { error in
            XCTAssertEqual(
                error as? TaggoError,
                .invalidRecordType(expected: RecordSchema.FoundReport.recordType, actual: "SomethingElse")
            )
        }
    }

    func test_toFoundReport_throwsOnMissingRequiredField() {
        let record = makeRecord()
        record[RecordSchema.FoundReport.Field.station] = nil

        XCTAssertThrowsError(try FoundReportMapper.toFoundReport(record: record)) { error in
            XCTAssertEqual(error as? TaggoError, .missingField(RecordSchema.FoundReport.Field.station))
        }
    }

    func test_toFoundReport_mapsClaimedStatusAndClaimedAt() throws {
        let claimedDate = Date(timeIntervalSince1970: 500)
        let record = makeRecord(status: .claimed, claimedAt: claimedDate)

        let report = try FoundReportMapper.toFoundReport(record: record)

        XCTAssertEqual(report.status, .claimed)
        XCTAssertEqual(report.claimedAt, claimedDate)
    }

    func test_toRecord_mapsAllFieldsOntoNewRecord() {
        let report = FoundReport(
            id: UUID(),
            itemID: UUID(),
            finderID: nil,
            station: "Airport",
            note: nil,
            photoData: nil,
            status: .pending,
            isRead: false,
            reportedAt: Date(timeIntervalSince1970: 10),
            claimedAt: nil
        )

        let record = FoundReportMapper.toRecord(report: report)

        XCTAssertEqual(record.recordType, RecordSchema.FoundReport.recordType)
        XCTAssertEqual(record.recordID.recordName, report.id.uuidString)
        XCTAssertEqual(record[RecordSchema.FoundReport.Field.itemID] as? String, report.itemID.uuidString)
        XCTAssertNil(record[RecordSchema.FoundReport.Field.finderID] as? String)
        XCTAssertEqual(record[RecordSchema.FoundReport.Field.station] as? String, "Airport")
        XCTAssertEqual(record[RecordSchema.FoundReport.Field.status] as? String, ReportStatus.pending.rawValue)
    }

    func test_roundTrip_recordToReportToRecordPreservesCoreFields() throws {
        let original = makeRecord()

        let report = try FoundReportMapper.toFoundReport(record: original)
        let roundTripped = FoundReportMapper.toRecord(report: report)

        XCTAssertEqual(roundTripped.recordID.recordName, original.recordID.recordName)
        XCTAssertEqual(roundTripped[RecordSchema.FoundReport.Field.station] as? String, original[RecordSchema.FoundReport.Field.station] as? String)
        XCTAssertEqual(roundTripped[RecordSchema.FoundReport.Field.status] as? String, original[RecordSchema.FoundReport.Field.status] as? String)
    }
}
