//
//  ListItemsUseCaseTests.swift
//  TaggoTests
//

import XCTest

final class ListItemsUseCaseTests: XCTestCase {
    private func makeItem(ownerID: UUID) -> Item {
        Item(
            id: UUID(),
            ownerID: ownerID,
            name: "Item",
            category: "Category",
            color: "Color",
            description: nil,
            imageData: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    func test_execute_fetchesItemsOwnedByCurrentUser() async throws {
        let currentUserProvider = MockCurrentUserProvider(currentUserID: UUID())
        let cloudKitManager = MockCloudKitManager()
        let expectedItems = [makeItem(ownerID: currentUserProvider.currentUserID)]
        cloudKitManager.fetchItemsResult = .success(expectedItems)
        let sut = ListItemsUseCase(cloudKitManager: cloudKitManager, currentUserProvider: currentUserProvider)

        let items = try await sut.execute()

        XCTAssertEqual(items, expectedItems)
        XCTAssertEqual(cloudKitManager.fetchItemsCount, 1)
        XCTAssertEqual(cloudKitManager.lastFetchItemsOwnerID, currentUserProvider.currentUserID)
    }

    func test_execute_whenNoItemsExist_returnsEmptyArray() async throws {
        let cloudKitManager = MockCloudKitManager()
        cloudKitManager.fetchItemsResult = .success([])
        let sut = ListItemsUseCase(cloudKitManager: cloudKitManager, currentUserProvider: MockCurrentUserProvider())

        let items = try await sut.execute()

        XCTAssertTrue(items.isEmpty)
    }

    func test_execute_whenFetchFails_propagatesError() async {
        let cloudKitManager = MockCloudKitManager()
        cloudKitManager.fetchItemsResult = .failure(TaggoError.networkUnavailable)
        let sut = ListItemsUseCase(cloudKitManager: cloudKitManager, currentUserProvider: MockCurrentUserProvider())

        do {
            _ = try await sut.execute()
            XCTFail("Expected execute to throw")
        } catch {
            XCTAssertEqual(error as? TaggoError, .networkUnavailable)
        }
    }
}
