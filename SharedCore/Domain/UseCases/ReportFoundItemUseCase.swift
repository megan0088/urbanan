//
//  ReportFoundItemUseCase.swift
//  SharedCore
//
//  Shared by the Main App's scan-others'-item flow AND the App Clip.
//

import Foundation

struct ReportFoundItemUseCase {

    /// Depends on FoundReportSubmitting (narrow), not CloudKitManaging directly — this is
    /// what lets Main App (direct CloudKit write) and the Clip (HTTP relay) share this
    /// exact UseCase despite having fundamentally different ways of actually getting the
    /// data saved.
    private let foundReportSubmitting: FoundReportSubmitting
    private let imageCompressor: ImageCompressing

    init(foundReportSubmitting: FoundReportSubmitting, imageCompressor: ImageCompressing) {
        self.foundReportSubmitting = foundReportSubmitting
        self.imageCompressor = imageCompressor
    }

    struct Input {
        var itemID: UUID
        var station: String
        var note: String
        var photoData: Data?
    }

    func execute(_ input: Input) async throws {
        let compressedPhoto = try input.photoData.map {
            try imageCompressor.compress($0, maxDimensionPixels: 1200, jpegQUality: 0.6)
        }

        let trimmedNote = input.note.trimmed
        let report = FoundReport(
            id: UUID(),
            itemID: input.itemID,
            station: input.station.trimmed,
            note: trimmedNote.isEmpty ? nil : trimmedNote,
            photoData: compressedPhoto,
            status: .pending,
            isRead: false,
            reportedAt: Date(),
            claimedAt: nil
        )

        try await foundReportSubmitting.submit(report)
    }
}
