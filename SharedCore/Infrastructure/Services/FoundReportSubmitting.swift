//
//  FoundReportSubmitting.swift
//  SharedCore
//

import Foundation

/// Narrow contract: submit a report, succeed or throw. No return value — neither
/// call site (Main App's report form, the Clip's) needs anything back beyond
/// success/failure for their UI.
protocol FoundReportSubmitting: Sendable {
    func submit(_ report: FoundReport) async throws
}
