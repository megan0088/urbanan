import XCTest
import CloudKit

final class FoundReportMapperTests: XCTestCase {

    func test_toRecord_toReport_roundTrip_preservesFields() throws {
        let report = FoundReport(
            id: UUID(),
            itemID: UUID(),
            station: "Central Station",
            note: "Left at the ticket counter",
            photoData: nil,
            status: .pending,
            isRead: false,
            reportedAt: Date(),
            claimedAt: nil
        )

        let record = FoundReportMapper.toRecord(report: report)
        let roundTripped = try FoundReportMapper.toFoundReport(record: record)

        XCTAssertEqual(roundTripped.id, report.id)
        XCTAssertEqual(roundTripped.itemID, report.itemID)
        XCTAssertEqual(roundTripped.station, report.station)
        XCTAssertEqual(roundTripped.note, report.note)
        XCTAssertEqual(roundTripped.status, report.status)
        XCTAssertEqual(roundTripped.isRead, report.isRead)
    }

    func test_toReport_throwsInvalidRecordType_forWrongRecordType() {
        let record = CKRecord(recordType: "NotAFoundReport")

        XCTAssertThrowsError(try FoundReportMapper.toFoundReport(record: record)) { error in
            guard case TaggoError.invalidRecordType = error else {
                return XCTFail("Expected invalidRecordType, got \(error)")
            }
        }
    }

    func test_toReport_throwsMissingField_whenStationMissing() {
        let record = CKRecord(recordType: RecordSchema.FoundReport.recordType)
        record[RecordSchema.FoundReport.Field.itemID] = UUID().uuidString
        record[RecordSchema.FoundReport.Field.status] = ReportStatus.pending.rawValue
        record[RecordSchema.FoundReport.Field.isRead] = false
        record[RecordSchema.FoundReport.Field.reportedAt] = Date()
        // station deliberately omitted

        XCTAssertThrowsError(try FoundReportMapper.toFoundReport(record: record)) { error in
            guard case TaggoError.missingField(let field) = error else {
                return XCTFail("Expected missingField, got \(error)")
            }
            XCTAssertEqual(field, RecordSchema.FoundReport.Field.station)
        }
    }
}
