//
//  MarkReportReadUseCase.swift
//  SharedCore
//

import Foundation

struct MarkReportReadUseCase {
    private let cloudKitManager: CloudKitManaging

    init(cloudKitManager: CloudKitManaging) {
        self.cloudKitManager = cloudKitManager
    }

    func execute(_ report: FoundReport) async throws -> FoundReport {
        guard !report.isRead else { return report }
        var updated = report
        updated.isRead = true
        return try await cloudKitManager.updateFoundReport(updated)
    }
}
