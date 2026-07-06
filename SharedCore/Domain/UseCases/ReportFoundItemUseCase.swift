//
//  ReportFoundItemUseCase.swift
//  SharedCore
//
//  Shared by the Main App's scan-others'-item flow AND the App Clip.
//

import Foundation

struct ReportFoundItemUseCase {
    
    private let cloudKitManager: CloudKitManaging
    private let imageCompressor: ImageCompressing
    
    init(cloudKitManager: CloudKitManaging, imageCompressor: ImageCompressing) {
        self.cloudKitManager = cloudKitManager
        self.imageCompressor = imageCompressor
    }
    
    struct Input {
        var itemID: UUID
        var station: String
        var note: String
        var photoData: Data?
    }
    
    struct Output {
        var report: FoundReport
    }
    
    func execute(_ input: Input) async throws -> Output {
        let compressedPhoto = try input.photoData.map {
            try imageCompressor.compress($0, maxDimensionPixels: 1200, jpegQUality: 0.6)
        }
        
        let now = Date()
        let newReport = FoundReport(
                id: UUID(),
                itemID: input.itemID,
                station: input.station,
                photoData: compressedPhoto,
                status: .pending,
                isRead: false,
                reportedAt: now,
                claimedAt: nil);
        let savedReport = try await cloudKitManager.saveFoundReport(newReport)
        return Output(report: savedReport);
    }
}
