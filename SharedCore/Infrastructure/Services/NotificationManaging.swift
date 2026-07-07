//
//  NotificationManaging.swift
//  SharedCore
//

import Foundation

protocol NotificationManaging: Sendable {
    func requestAuthorization() async throws -> Bool
    func subscribeToFoundReports(forItemID itemID: UUID) async throws
    func handleRemoteNotification() async
    var foundReportEvents: AsyncStream<Void> { get }
}
