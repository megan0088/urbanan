//
//  MarkReportClaimedUseCaseTests.swift
//  TaggoTests
//

import XCTest

final class MarkReportClaimedUseCaseTests: XCTestCase {
    private func makeReport(status: ReportStatus = .pending) -> FoundReport {
        FoundReport(
            id: UUID(), itemID: UUID(), station: "Station", note: nil, photoData: nil,
            status: status, isRead: false, reportedAt: Date(), claimedAt: nil
        )
    }

    func test_execute_marksReportClaimedWithTimestamp() async throws {
        let report = makeReport()
        let cloudKitManager = MockCloudKitManager()
        let sut = MarkReportClaimedUseCase(cloudKitManager: cloudKitManager)

        let updated = try await sut.execute(report)

        XCTAssertEqual(updated.status, .claimed)
        XCTAssertNotNil(updated.claimedAt)
        XCTAssertEqual(cloudKitManager.updateFoundReportCallCount, 1)
        XCTAssertEqual(cloudKitManager.lastUpdatedFoundReport?.id, report.id)
        XCTAssertEqual(cloudKitManager.lastUpdatedFoundReport?.status, .claimed)
    }

    func test_execute_whenUpdateFails_propagatesError() async {
        let cloudKitManager = MockCloudKitManager()
        cloudKitManager.updateFoundReportResult = .failure(TaggoError.networkUnavailable)
        let sut = MarkReportClaimedUseCase(cloudKitManager: cloudKitManager)

        do {
            _ = try await sut.execute(makeReport())
            XCTFail("Expected error")
        } catch let error as TaggoError {
            XCTAssertEqual(error, .networkUnavailable)
        } catch {
            XCTFail("Expected TaggoError, got \(error)")
        }
    }
}
