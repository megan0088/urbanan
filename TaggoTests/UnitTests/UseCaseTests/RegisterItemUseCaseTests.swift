//
//  RegisterItemUseCaseTests.swift
//  TaggoTests
//

import XCTest

final class RegisterItemUseCaseTests: XCTestCase {
    private func makeSUT(
        cloudKitManager: MockCloudKitManager = MockCloudKitManager(),
        qrManager: MockQRManager = MockQRManager(),
        currentUserProvider: MockCurrentUserProvider = MockCurrentUserProvider(),
        imageCompressor: MockImageCompressor = MockImageCompressor(),
        notificationManaging: MockNotificationManaging = MockNotificationManaging()
    ) -> RegisterItemUseCase {
        RegisterItemUseCase(
            cloudKitManager: cloudKitManager,
            qrManager: qrManager,
            currentUserProvider: currentUserProvider,
            imageCompressor: imageCompressor,
            notificationManaging: notificationManaging
        )
    }

    func test_execute_savesItemWithCurrentUserAsOwner() async throws {
        let currentUserProvider = MockCurrentUserProvider(currentUserID: UUID())
        let cloudKitManager = MockCloudKitManager()
        let sut = makeSUT(cloudKitManager: cloudKitManager, currentUserProvider: currentUserProvider)

        let input = RegisterItemUseCase.Input(name: "Blue Backpack", category: "Bags", color: "Blue", description: "Worn straps", imageData: nil)
        _ = try await sut.execute(input)

        XCTAssertEqual(cloudKitManager.saveItemCallCount, 1)
        XCTAssertEqual(cloudKitManager.lastSavedItem?.ownerID, currentUserProvider.currentUserID)
        XCTAssertEqual(cloudKitManager.lastSavedItem?.name, "Blue Backpack")
        XCTAssertEqual(cloudKitManager.lastSavedItem?.category, "Bags")
        XCTAssertEqual(cloudKitManager.lastSavedItem?.color, "Blue")
        XCTAssertEqual(cloudKitManager.lastSavedItem?.description, "Worn straps")
    }

    func test_execute_withNoImage_skipsCompressionAndSavesNilImageData() async throws {
        let imageCompressor = MockImageCompressor()
        let cloudKitManager = MockCloudKitManager()
        let sut = makeSUT(cloudKitManager: cloudKitManager, imageCompressor: imageCompressor)

        let input = RegisterItemUseCase.Input(name: "Item", category: "Cat", color: "Red", description: "", imageData: nil)
        _ = try await sut.execute(input)

        XCTAssertEqual(imageCompressor.compressCallCount, 0)
        XCTAssertNil(cloudKitManager.lastSavedItem?.imageData)
    }

    func test_execute_withImage_savesCompressedImageData() async throws {
        let imageCompressor = MockImageCompressor()
        let compressedData = Data("compressed".utf8)
        imageCompressor.compressResult = .success(compressedData)
        let cloudKitManager = MockCloudKitManager()
        let sut = makeSUT(cloudKitManager: cloudKitManager, imageCompressor: imageCompressor)

        let rawImageData = Data("raw-image-bytes".utf8)
        let input = RegisterItemUseCase.Input(name: "Item", category: "Cat", color: "Red", description: "", imageData: rawImageData)
        _ = try await sut.execute(input)

        XCTAssertEqual(imageCompressor.compressCallCount, 1)
        XCTAssertEqual(imageCompressor.lastInputData, rawImageData)
        XCTAssertEqual(cloudKitManager.lastSavedItem?.imageData, compressedData)
    }

    func test_execute_returnsQRCodeAndLinkForSavedItem() async throws {
        let qrManager = MockQRManager()
        let qrData = Data("qr-bytes".utf8)
        qrManager.generateQRCodeResult = .success(qrData)
        let sut = makeSUT(qrManager: qrManager)

        let input = RegisterItemUseCase.Input(name: "Item", category: "Cat", color: "Red", description: "", imageData: nil)
        let output = try await sut.execute(input)

        XCTAssertEqual(output.qrCodeImageData, qrData)
        XCTAssertEqual(qrManager.lastRequestedItemID, output.item.id)
        XCTAssertEqual(output.itemLink, qrManager.link(for: output.item.id))
    }

    func test_execute_whenSaveFails_propagatesError() async {
        let cloudKitManager = MockCloudKitManager()
        cloudKitManager.saveItemResult = .failure(TaggoError.networkUnavailable)
        let sut = makeSUT(cloudKitManager: cloudKitManager)

        let input = RegisterItemUseCase.Input(name: "Item", category: "Cat", color: "Red", description: "", imageData: nil)

        do {
            _ = try await sut.execute(input)
            XCTFail("Expected execute to throw")
        } catch {
            XCTAssertEqual(error as? TaggoError, .networkUnavailable)
        }
    }

    func test_execute_whenCompressionFails_propagatesErrorWithoutSaving() async {
        let imageCompressor = MockImageCompressor()
        imageCompressor.compressResult = .failure(TaggoError.invalidFieldValue("imageData"))
        let cloudKitManager = MockCloudKitManager()
        let sut = makeSUT(cloudKitManager: cloudKitManager, imageCompressor: imageCompressor)

        let input = RegisterItemUseCase.Input(name: "Item", category: "Cat", color: "Red", description: "", imageData: Data("raw".utf8))

        do {
            _ = try await sut.execute(input)
            XCTFail("Expected execute to throw")
        } catch {
            XCTAssertEqual(error as? TaggoError, .invalidFieldValue("imageData"))
        }
        XCTAssertEqual(cloudKitManager.saveItemCallCount, 0)
    }

    func test_execute_subscribesToFoundReportsForSavedItem() async throws {
        let notificationManaging = MockNotificationManaging()
        let sut = makeSUT(notificationManaging: notificationManaging)

        let input = RegisterItemUseCase.Input(name: "Blue Backpack", category: "Cat", color: "Red", description: "", imageData: nil)
        let output = try await sut.execute(input)

        XCTAssertEqual(notificationManaging.subscribeCallCount, 1)
        XCTAssertEqual(notificationManaging.lastSubscribedItemID, output.item.id)
        XCTAssertEqual(notificationManaging.lastSubscribedItemName, "Blue Backpack")
    }

    func test_execute_whenSubscriptionFails_registrationStillSucceeds() async throws {
        let notificationManaging = MockNotificationManaging()
        notificationManaging.subscribeResult = .failure(TaggoError.networkUnavailable)
        let sut = makeSUT(notificationManaging: notificationManaging)

        let input = RegisterItemUseCase.Input(name: "Item", category: "Cat", color: "Red", description: "", imageData: nil)

        // Should not throw even though the subscription failed.
        _ = try await sut.execute(input)
    }
}
