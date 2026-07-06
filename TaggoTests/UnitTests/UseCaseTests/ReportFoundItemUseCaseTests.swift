//
//  ReportFoundItemUseCaseTests.swift
//  TaggoTests
//

import XCTest

final class ReportFoundItemUseCaseTests: XCTestCase {

    func test_execute_savesReportWithPendingStatusAndUnread() async throws {
        let mockCK = MockCloudKitManager()
        let useCase = ReportFoundItemUseCase(
            cloudKitManager: mockCK,
            imageCompressor: MockImageCompressor()
        )

        let itemID = UUID()
        let input = ReportFoundItemUseCase.Input(
            itemID: itemID, station: "Central Station", note: "By the ticket gate", photoData: nil
        )

        let output = try await useCase.execute(input)

        XCTAssertEqual(mockCK.saveFoundReportCallCount, 1)
        XCTAssertEqual(output.report.itemID, itemID)
        XCTAssertEqual(output.report.station, "Central Station")
        XCTAssertEqual(output.report.status, .pending)
        XCTAssertFalse(output.report.isRead)
    }

    func test_execute_compressesPhoto_whenProvided() async throws {
        let mockCK = MockCloudKitManager()
        let mockCompressor = MockImageCompressor()
        let compressedData = Data("compressed-photo".utf8)
        mockCompressor.compressResult = .success(compressedData)
        let useCase = ReportFoundItemUseCase(cloudKitManager: mockCK, imageCompressor: mockCompressor)

        let input = ReportFoundItemUseCase.Input(
            itemID: UUID(), station: "Station", note: "", photoData: Data("raw-photo".utf8)
        )

        let output = try await useCase.execute(input)

        XCTAssertEqual(mockCompressor.compressCallCount, 1)
        XCTAssertEqual(output.report.photoData, compressedData)
        XCTAssertEqual(mockCK.lastSavedFoundReport?.photoData, compressedData)
    }

    func test_execute_doesNotCallCompressor_whenNoPhotoProvided() async throws {
        let mockCompressor = MockImageCompressor()
        let useCase = ReportFoundItemUseCase(
            cloudKitManager: MockCloudKitManager(),
            imageCompressor: mockCompressor
        )

        let input = ReportFoundItemUseCase.Input(
            itemID: UUID(), station: "Station", note: "", photoData: nil
        )

        _ = try await useCase.execute(input)

        XCTAssertEqual(mockCompressor.compressCallCount, 0)
    }

    func test_execute_propagatesCloudKitError() async {
        let mockCK = MockCloudKitManager()
        mockCK.saveFoundReportResult = .failure(TaggoError.networkUnavailable)
        let useCase = ReportFoundItemUseCase(cloudKitManager: mockCK, imageCompressor: MockImageCompressor())

        let input = ReportFoundItemUseCase.Input(
            itemID: UUID(), station: "Station", note: "", photoData: nil
        )

        do {
            _ = try await useCase.execute(input)
            XCTFail("Expected error")
        } catch let error as TaggoError {
            XCTAssertEqual(error, .networkUnavailable)
        } catch {
            
        }
    }

    func test_execute_convertsEmptyNoteToNil() async throws {
        let mockCK = MockCloudKitManager()
        let useCase = ReportFoundItemUseCase(cloudKitManager: mockCK, imageCompressor: MockImageCompressor())

        let input = ReportFoundItemUseCase.Input(
            itemID: UUID(), station: "Station", note: "", photoData: nil
        )

        let output = try await useCase.execute(input)

        XCTAssertNil(output.report.note)
    }
}
