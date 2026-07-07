//
//  ReportFoundItemUseCaseTests.swift
//  TaggoTests
//

import XCTest

final class ReportFoundItemUseCaseTests: XCTestCase {

    func test_execute_submitsReportWithGivenFields() async throws {
        let mockSubmitter = MockFoundReportSubmitting()
        let useCase = ReportFoundItemUseCase(
            foundReportSubmitting: mockSubmitter,
            imageCompressor: MockImageCompressor()
        )

        let itemID = UUID()
        let input = ReportFoundItemUseCase.Input(
            itemID: itemID, station: "Central Station", note: "By the ticket gate", photoData: nil
        )

        try await useCase.execute(input)

        XCTAssertEqual(mockSubmitter.submitCallCount, 1)
        XCTAssertEqual(mockSubmitter.lastSubmittedReport?.itemID, itemID)
        XCTAssertEqual(mockSubmitter.lastSubmittedReport?.station, "Central Station")
        XCTAssertEqual(mockSubmitter.lastSubmittedReport?.status, .pending)
        XCTAssertFalse(mockSubmitter.lastSubmittedReport?.isRead ?? true)
    }

    func test_execute_compressesPhoto_whenProvided() async throws {
        let mockSubmitter = MockFoundReportSubmitting()
        let mockCompressor = MockImageCompressor()
        let compressedData = Data("compressed-photo".utf8)
        mockCompressor.compressResult = .success(compressedData)
        let useCase = ReportFoundItemUseCase(foundReportSubmitting: mockSubmitter, imageCompressor: mockCompressor)

        let input = ReportFoundItemUseCase.Input(
            itemID: UUID(), station: "Station", note: "", photoData: Data("raw-photo".utf8)
        )

        try await useCase.execute(input)

        XCTAssertEqual(mockCompressor.compressCallCount, 1)
        XCTAssertEqual(mockSubmitter.lastSubmittedReport?.photoData, compressedData)
    }

    func test_execute_doesNotCallCompressor_whenNoPhotoProvided() async throws {
        let mockCompressor = MockImageCompressor()
        let useCase = ReportFoundItemUseCase(
            foundReportSubmitting: MockFoundReportSubmitting(),
            imageCompressor: mockCompressor
        )

        let input = ReportFoundItemUseCase.Input(
            itemID: UUID(), station: "Station", note: "", photoData: nil
        )

        try await useCase.execute(input)

        XCTAssertEqual(mockCompressor.compressCallCount, 0)
    }

    func test_execute_propagatesSubmissionError() async {
        let mockSubmitter = MockFoundReportSubmitting()
        mockSubmitter.submitResult = .failure(TaggoError.networkUnavailable)
        let useCase = ReportFoundItemUseCase(
            foundReportSubmitting: mockSubmitter,
            imageCompressor: MockImageCompressor()
        )

        let input = ReportFoundItemUseCase.Input(
            itemID: UUID(), station: "Station", note: "", photoData: nil
        )

        do {
            try await useCase.execute(input)
            XCTFail("Expected error")
        } catch let error as TaggoError {
            XCTAssertEqual(error, .networkUnavailable)
        } catch {
            XCTFail("Expected TaggoError, got \(error)")
        }
    }

    func test_execute_convertsEmptyNoteToNil() async throws {
        let mockSubmitter = MockFoundReportSubmitting()
        let useCase = ReportFoundItemUseCase(foundReportSubmitting: mockSubmitter, imageCompressor: MockImageCompressor())

        let input = ReportFoundItemUseCase.Input(
            itemID: UUID(), station: "Station", note: "", photoData: nil
        )

        try await useCase.execute(input)

        XCTAssertNil(mockSubmitter.lastSubmittedReport?.note)
    }

    func test_execute_keepsNonEmptyNote() async throws {
        let mockSubmitter = MockFoundReportSubmitting()
        let useCase = ReportFoundItemUseCase(foundReportSubmitting: mockSubmitter, imageCompressor: MockImageCompressor())

        let input = ReportFoundItemUseCase.Input(
            itemID: UUID(), station: "Station", note: "By the ticket gate", photoData: nil
        )

        try await useCase.execute(input)

        XCTAssertEqual(mockSubmitter.lastSubmittedReport?.note, "By the ticket gate")
    }
}
