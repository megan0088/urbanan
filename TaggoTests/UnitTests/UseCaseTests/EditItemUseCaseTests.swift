//
//  EditItemUseCaseTests.swift
//  TaggoTests
//

import XCTest

final class EditItemUseCaseTests: XCTestCase {

    private func makeExistingItem(ownerID: UUID) -> Item {
        Item(
            id: UUID(), ownerID: ownerID, name: "Old Name", category: "Old Category",
            color: "Old Color", description: "Old description", imageData: nil,
            createdAt: Date(), updatedAt: Date()
        )
    }

    func test_execute_updatesFieldsAndBumpsUpdatedAt() async throws {
        let ownerID = UUID()
        let existing = makeExistingItem(ownerID: ownerID)
        let mockCK = MockCloudKitManager()
        mockCK.fetchItemResult = .success(existing)
        let useCase = EditItemUseCase(
            cloudKitManager: mockCK,
            currentUserProvider: MockCurrentUserProvider(currentUserID: ownerID),
            imageCompressor: MockImageCompressor()
        )

        let input = EditItemUseCase.Input(
            itemID: existing.id, name: "New Name", category: "New Category",
            color: "New Color", description: "New description", imageData: nil
        )

        let updated = try await useCase.execute(input)

        XCTAssertEqual(mockCK.updateItemCallCount, 1)
        XCTAssertEqual(updated.name, "New Name")
        XCTAssertEqual(updated.category, "New Category")
        XCTAssertEqual(updated.id, existing.id)
        XCTAssertEqual(updated.ownerID, existing.ownerID)
        XCTAssertGreaterThanOrEqual(updated.updatedAt, existing.updatedAt)
    }

    func test_execute_throwsNotOwner_whenCallerIsNotTheOwner() async {
        let existing = makeExistingItem(ownerID: UUID())
        let mockCK = MockCloudKitManager()
        mockCK.fetchItemResult = .success(existing)
        let useCase = EditItemUseCase(
            cloudKitManager: mockCK,
            currentUserProvider: MockCurrentUserProvider(userID: UUID()), // different user
            imageCompressor: MockImageCompressor()
        )

        let input = EditItemUseCase.Input(
            itemID: existing.id, name: "Hacked", category: "X", color: "X", description: "", imageData: nil
        )

        do {
            _ = try await useCase.execute(input)
            XCTFail("Expected TaggoError.notOwner")
        } catch let error as TaggoError {
            XCTAssertEqual(error, .notOwner)
        }

        XCTAssertEqual(mockCK.updateItemCallCount, 0)
    }

    func test_execute_keepsExistingPhoto_whenNoNewPhotoProvided() async throws {
        let ownerID = UUID()
        var existing = makeExistingItem(ownerID: ownerID)
        existing.imageData = Data("old-photo".utf8)
        let mockCK = MockCloudKitManager()
        mockCK.fetchItemResult = .success(existing)
        let useCase = EditItemUseCase(
            cloudKitManager: mockCK,
            currentUserProvider: MockCurrentUserProvider(userID: ownerID),
            imageCompressor: MockImageCompressor()
        )

        let input = EditItemUseCase.Input(
            itemID: existing.id, name: "New Name", category: "X", color: "X", description: "", imageData: nil
        )

        let updated = try await useCase.execute(input)

        XCTAssertEqual(updated.imageData, Data("old-photo".utf8))
    }

    func test_execute_propagatesFetchError() async {
        let mockCK = MockCloudKitManager()
        mockCK.fetchItemResult = .failure(TaggoError.notFound)
        let useCase = EditItemUseCase(
            cloudKitManager: mockCK,
            currentUserProvider: MockCurrentUserProvider(),
            imageCompressor: MockImageCompressor()
        )

        let input = EditItemUseCase.Input(
            itemID: UUID(), name: "X", category: "X", color: "X", description: "", imageData: nil
        )

        do {
            _ = try await useCase.execute(input)
            XCTFail("Expected error")
        } catch let error as TaggoError {
            XCTAssertEqual(error, .notFound)
        }
    }
}
