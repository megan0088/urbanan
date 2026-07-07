//
//  HTTPFoundReportSubmitter.swift
//  TaggoClip
//

import Foundation

/// Clip-only. Plain HTTPS POST to a relay endpoint — no CloudKit framework calls at all,
/// since App Clips get the CloudKit-Anonymous entitlement mode, which is READ-ONLY at
/// the platform level (per Apple's own documentation, not a permissions
/// misconfiguration — no Security Roles change can override this).
///
/// NOTE: the relay endpoint is not deployed yet. This implementation is complete and
/// ready to use the moment that endpoint exists — pointed at
/// AppConfiguration.reportRelayURL, currently a placeholder.
final class HTTPFoundReportSubmitter: FoundReportSubmitting {
    private let endpoint: URL
    private let urlSession: URLSession

    init(endpoint: URL = AppConfiguration.reportRelayURL, urlSession: URLSession = .shared) {
        self.endpoint = endpoint
        self.urlSession = urlSession
    }

    private struct RequestBody: Encodable {
        let itemID: String
        let station: String
        let note: String?
        let photoDataBase64: String?
    }

    func submit(_ report: FoundReport) async throws {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = RequestBody(
            itemID: report.itemID.uuidString,
            station: report.station,
            note: report.note,
            photoDataBase64: report.photoData?.base64EncodedString()
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw TaggoError.unknown("Report submission failed")
        }
    }
}
