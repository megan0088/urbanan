//
//  FetchInboxUseCaseTests.swift
//  TaggoTests
//

import XCTest

final class FetchInboxUseCaseTests: XCTestCase {
    private func makeItem(id: UUID = UUID(), ownerID: UUID) -> Item {
        Item(
            id: id, ownerID: ownerID, name: "Item", category: "Category", color: "Color",
            description: nil, imageData: nil, createdAt: Date(), updatedAt: Date()
        )
    }

    private func makeReport(itemID: UUID, reportedAt: Date) -> FoundReport {
        FoundReport(
            id: UUID(), itemID: itemID, station: "Station", note: nil, photoData: nil,
            status: .pending, isRead: false, reportedAt: reportedAt, claimedAt: nil
        )
    }

    func test_execute_returnsReportsForCurrentUsersItems() async throws {
        let ownerID = UUID()
        let currentUserProvider = MockCurrentUserProvider(currentUserID: ownerID)
        let item = makeItem(ownerID: ownerID)
        let cloudKitManager = MockCloudKitManager()
        cloudKitManager.fetchItemsResult = .success([item])
        let report = makeReport(itemID: item.id, reportedAt: Date())
        cloudKitManager.fetchFoundReportsResult = .success([report])

        let sut = FetchInboxUseCase(cloudKitManager: cloudKitManager, currentUserProvider: currentUserProvider)
        let reports = try await sut.execute()

        XCTAssertEqual(reports, [report])
        XCTAssertEqual(cloudKitManager.lastFetchItemsOwnerID, ownerID)
        XCTAssertEqual(cloudKitManager.lastFetchFoundReportsItemIDs, [item.id])
    }

    func test_execute_whenUserHasNoItems_skipsReportFetchAndReturnsEmpty() async throws {
        let cloudKitManager = MockCloudKitManager()
        cloudKitManager.fetchItemsResult = .success([])
        let sut = FetchInboxUseCase(cloudKitManager: cloudKitManager, currentUserProvider: MockCurrentUserProvider())

        let reports = try await sut.execute()

        XCTAssertTrue(reports.isEmpty)
        XCTAssertEqual(cloudKitManager.fetchFoundReportsCallCount, 0)
    }

    func test_execute_sortsReportsNewestFirst() async throws {
        let ownerID = UUID()
        let item = makeItem(ownerID: ownerID)
        let older = makeReport(itemID: item.id, reportedAt: Date(timeIntervalSince1970: 0))
        let newer = makeReport(itemID: item.id, reportedAt: Date(timeIntervalSince1970: 1000))
        let cloudKitManager = MockCloudKitManager()
        cloudKitManager.fetchItemsResult = .success([item])
        cloudKitManager.fetchFoundReportsResult = .success([older, newer])

        let sut = FetchInboxUseCase(cloudKitManager: cloudKitManager, currentUserProvider: MockCurrentUserProvider(currentUserID: ownerID))
        let reports = try await sut.execute()

        XCTAssertEqual(reports.map(\.id), [newer.id, older.id])
    }

    func test_execute_whenFetchItemsFails_propagatesError() async {
        let cloudKitManager = MockCloudKitManager()
        cloudKitManager.fetchItemsResult = .failure(TaggoError.networkUnavailable)
        let sut = FetchInboxUseCase(cloudKitManager: cloudKitManager, currentUserProvider: MockCurrentUserProvider())

        do {
            _ = try await sut.execute()
            XCTFail("Expected error")
        } catch let error as TaggoError {
            XCTAssertEqual(error, .networkUnavailable)
        } catch {
            XCTFail("Expected TaggoError, got \(error)")
        }
    }
}
