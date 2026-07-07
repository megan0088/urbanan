//
//  NotificationManaging.swift
//  SharedCore
//

import Foundation

/// Lives in SharedCore (not TaggoMain) so RegisterItemUseCase can depend on it —
/// the concrete CloudKit/UserNotifications-backed implementation stays TaggoMain-only,
/// since only the owner side ever actually constructs one.
protocol NotificationManaging: Sendable {
    func requestAuthorization() async throws -> Bool
    func subscribeToFoundReports(forItemID itemID: UUID) async throws
    func handleRemoteNotification() async
    var foundReportEvents: AsyncStream<Void> { get }

    /// Diagnostic-only: lists subscriptions currently registered server-side, so a silent
    /// `subscribeToFoundReports` failure (e.g. a non-queryable predicate field) can be
    /// confirmed directly instead of inferred from "notifications never arrive."
    func debugListSubscriptions() async throws -> [String]
}
