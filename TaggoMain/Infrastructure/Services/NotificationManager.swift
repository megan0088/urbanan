import Foundation
import CloudKit
import UserNotifications

final class NotificationManager: NSObject, NotificationManaging, @unchecked Sendable {
    private let database: CKDatabase
    private let continuation: AsyncStream<Void>.Continuation
    let foundReportEvents: AsyncStream<Void>

    init(database: CKDatabase = CKContainer(identifier: AppConfiguration.cloudKitContainerIdentifier).publicCloudDatabase) {
        self.database = database
        var continuation: AsyncStream<Void>.Continuation!
        self.foundReportEvents = AsyncStream { continuation = $0 }
        self.continuation = continuation
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
    }

    func subscribeToFoundReports(forItemID itemID: UUID) async throws {
        let predicate = NSPredicate(format: "%K == %@", RecordSchema.FoundReport.Field.itemID, itemID.uuidString)
        let subscription = CKQuerySubscription(
            recordType: RecordSchema.FoundReport.recordType,
            predicate: predicate,
            subscriptionID: "found-report-\(itemID.uuidString)",
            options: [.firesOnRecordCreation]
        )
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "Item Found"
        notificationInfo.alertBody = "Someone reported \(itemID) as found. Check your Inbox for details."
        notificationInfo.soundName = "default"
        notificationInfo.shouldBadge = true
        notificationInfo.shouldSendContentAvailable = true 
        subscription.notificationInfo = notificationInfo

        do {
            let saved = try await database.save(subscription)
            print("✅ Subscribed to found reports — subscriptionID: \(saved.subscriptionID), itemID: \(itemID.uuidString)")
        } catch let error as CKError {
            print("❌ Subscription save failed for itemID \(itemID.uuidString): \(error) — serverMessage: \(error.userInfo[NSLocalizedDescriptionKey] ?? "none")")
            throw Self.map(error)
        }
    }

    func handleRemoteNotification() async {
        continuation.yield(())
    }

    private static func map(_ error: CKError) -> TaggoError {
        switch error.code {
        case .networkUnavailable, .networkFailure:
            return .networkUnavailable
        case .permissionFailure, .notAuthenticated:
            return .unauthorized
        case .quotaExceeded:
            return .quotaExceeded
        default:
            return .unknown(error.localizedDescription)
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }
}
