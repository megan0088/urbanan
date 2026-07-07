//
//  MarkReportClaimedUseCase.swift
//  SharedCore
//

import Foundation

struct MarkReportClaimedUseCase {
    private let cloudKitManager: CloudKitManaging

    init(cloudKitManager: CloudKitManaging) {
        self.cloudKitManager = cloudKitManager
    }

    func execute(_ report: FoundReport) async throws -> FoundReport {
        var updated = report
        updated.status = .claimed
        updated.claimedAt = Date()
        return try await cloudKitManager.updateFoundReport(updated)
    }
}
