//
//  MockNotificationManaging.swift
//  TaggoTests
//

import Foundation

final class MockNotificationManaging: NotificationManaging, @unchecked Sendable {
    var requestAuthorizationResult: Result<Bool, Error> = .success(true)
    private(set) var requestAuthorizationCallCount = 0

    var subscribeResult: Result<Void, Error> = .success(())
    private(set) var subscribeCallCount = 0
    private(set) var lastSubscribedItemID: UUID?
    private(set) var lastSubscribedItemName: String?

    var debugListSubscriptionsResult: Result<[String], Error> = .success([])
    private(set) var debugListSubscriptionsCallCount = 0

    let foundReportEvents: AsyncStream<Void>
    private let foundReportEventsContinuation: AsyncStream<Void>.Continuation

    init() {
        var continuation: AsyncStream<Void>.Continuation!
        foundReportEvents = AsyncStream { continuation = $0 }
        foundReportEventsContinuation = continuation
    }

    func requestAuthorization() async throws -> Bool {
        requestAuthorizationCallCount += 1
        switch requestAuthorizationResult {
        case .success(let granted): return granted
        case .failure(let error): throw error
        }
    }

    func subscribeToFoundReports(forItemID itemID: UUID, itemName: String) async throws {
        subscribeCallCount += 1
        lastSubscribedItemID = itemID
        lastSubscribedItemName = itemName
        if case .failure(let error) = subscribeResult {
            throw error
        }
    }

    func emitFoundReportEvent() {
        foundReportEventsContinuation.yield(())
    }

    private(set) var handleRemoteNotificationCallCount = 0

    func handleRemoteNotification() async {
        handleRemoteNotificationCallCount += 1
    }

    func debugListSubscriptions() async throws -> [String] {
        debugListSubscriptionsCallCount += 1
        switch debugListSubscriptionsResult {
        case .success(let subscriptions): return subscriptions
        case .failure(let error): throw error
        }
    }
}
