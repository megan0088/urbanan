//
//  DeleteItemUseCaseTests.swift
//  TaggoTests
//

import XCTest

final class DeleteItemUseCaseTests: XCTestCase {

    private func makeItem(ownerID: UUID) -> Item {
        Item(
            id: UUID(), ownerID: ownerID, name: "Item", category: "Category",
            color: "Color", description: nil, imageData: nil, createdAt: Date(), updatedAt: Date()
        )
    }

    func test_execute_deletesItem_whenCallerIsOwner() async throws {
        let ownerID = UUID()
        let item = makeItem(ownerID: ownerID)
        let mockCK = MockCloudKitManager()
        mockCK.fetchItemResult = .success(item)
        let useCase = DeleteItemUseCase(
            cloudKitManager: mockCK,
            currentUserProvider: MockCurrentUserProvider(currentUserID: ownerID)
        )

        try await useCase.execute(itemID: item.id)

        XCTAssertEqual(mockCK.deleteItemCallCount, 1)
        XCTAssertEqual(mockCK.lastDeletedItemID, item.id)
    }

    func test_execute_throwsNotOwner_andNeverDeletes_whenCallerIsNotOwner() async {
        let item = makeItem(ownerID: UUID())
        let mockCK = MockCloudKitManager()
        mockCK.fetchItemResult = .success(item)
        let useCase = DeleteItemUseCase(
            cloudKitManager: mockCK,
            currentUserProvider: MockCurrentUserProvider(currentUserID: UUID())
        )

        do {
            try await useCase.execute(itemID: item.id)
            XCTFail("Expected TaggoError.notOwner")
        } catch let error as TaggoError {
            XCTAssertEqual(error, .notOwner)
        } catch {
            
        }

        XCTAssertEqual(mockCK.deleteItemCallCount, 0)
    }

    func test_execute_propagatesFetchError() async {
        let mockCK = MockCloudKitManager()
        mockCK.fetchItemResult = .failure(TaggoError.networkUnavailable)
        let useCase = DeleteItemUseCase(
            cloudKitManager: mockCK,
            currentUserProvider: MockCurrentUserProvider()
        )

        do {
            try await useCase.execute(itemID: UUID())
            XCTFail("Expected error")
        } catch let error as TaggoError {
            XCTAssertEqual(error, .networkUnavailable)
        } catch {
            
        }

        XCTAssertEqual(mockCK.deleteItemCallCount, 0)
    }
}
