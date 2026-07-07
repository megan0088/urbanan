//
//  CloudKitFoundReportSubmitter.swift
//  SharedCore
//

import Foundation

/// Main App's implementation — writes directly via CloudKit. Unaffected by the App
/// Clip's CloudKit-Anonymous read-only restriction, since Main App's entitlement
/// isn't scoped that way.
struct CloudKitFoundReportSubmitter: FoundReportSubmitting {
    private let cloudKitManager: CloudKitManaging

    init(cloudKitManager: CloudKitManaging) {
        self.cloudKitManager = cloudKitManager
    }

    func submit(_ report: FoundReport) async throws {
        _ = try await cloudKitManager.saveFoundReport(report)
    }
}
