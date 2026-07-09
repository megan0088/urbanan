//
//  MarkReportReadUseCaseTests.swift
//  TaggoTests
//

import XCTest

final class MarkReportReadUseCaseTests: XCTestCase {
    private func makeReport(isRead: Bool = false) -> FoundReport {
        FoundReport(
            id: UUID(), itemID: UUID(), station: "Station", note: nil, photoData: nil,
            status: .pending, isRead: isRead, reportedAt: Date(), claimedAt: nil
        )
    }

    func test_execute_marksReportRead() async throws {
        let report = makeReport(isRead: false)
        let cloudKitManager = MockCloudKitManager()
        let sut = MarkReportReadUseCase(cloudKitManager: cloudKitManager)

        let updated = try await sut.execute(report)

        XCTAssertTrue(updated.isRead)
        XCTAssertEqual(cloudKitManager.updateFoundReportCallCount, 1)
        XCTAssertEqual(cloudKitManager.lastUpdatedFoundReport?.id, report.id)
    }

    func test_execute_whenAlreadyRead_skipsUpdate() async throws {
        let report = makeReport(isRead: true)
        let cloudKitManager = MockCloudKitManager()
        let sut = MarkReportReadUseCase(cloudKitManager: cloudKitManager)

        let updated = try await sut.execute(report)

        XCTAssertTrue(updated.isRead)
        XCTAssertEqual(cloudKitManager.updateFoundReportCallCount, 0)
    }

    func test_execute_whenUpdateFails_propagatesError() async {
        let cloudKitManager = MockCloudKitManager()
        cloudKitManager.updateFoundReportResult = .failure(TaggoError.networkUnavailable)
        let sut = MarkReportReadUseCase(cloudKitManager: cloudKitManager)

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
