//
//  MockFoundReportSubmitting.swift
//  TaggoTests
//

import Foundation

final class MockFoundReportSubmitting: FoundReportSubmitting, @unchecked Sendable {
    var submitResult: Result<Void, Error> = .success(())
    private(set) var submitCallCount = 0
    private(set) var lastSubmittedReport: FoundReport?

    func submit(_ report: FoundReport) async throws {
        submitCallCount += 1
        lastSubmittedReport = report
        if case .failure(let error) = submitResult {
            throw error
        }
    }
}
