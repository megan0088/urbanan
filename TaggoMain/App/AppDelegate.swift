//
//  AppDelegate.swift
//  TaggoMain
//

import UIKit
import CloudKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    var notificationManager: NotificationManaging?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        application.registerForRemoteNotifications()

        // Centralizing this here (rather than relying on some specific screen being
        // opened) guarantees requestAuthorization() actually runs every launch — this
        // is what was silently missing, confirmed by Settings > Taggo having no
        // Notifications entry at all (iOS only creates that entry once this has been
        // called at least once, ever).
        Task {
            do {
                let granted = try await notificationManager?.requestAuthorization()
                print("Notification authorization granted: \(String(describing: granted))")
            } catch {
                print("Notification authorization request failed: \(error)")
            }

            // Diagnostic: confirms whether subscribeToFoundReports actually persisted
            // anything server-side, since RegisterItemUseCase intentionally doesn't
            // fail registration when a subscription save fails.
            do {
                let subscriptions = try await notificationManager?.debugListSubscriptions() ?? []
                print("📋 Active CloudKit subscriptions (\(subscriptions.count)):")
                subscriptions.forEach { print("   - \($0)") }
            } catch {
                print("⚠️ Failed to list CloudKit subscriptions: \(error)")
            }
        }

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("Registered for remote notifications, token length: \(deviceToken.count)")
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications: \(error)")
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // If this print never shows up when submitting a report, the push never reached
        // the device at all — the failure is server-side (subscription missing, predicate
        // never matched, or the subscribing identity lacks Read access on FoundReport),
        // not in this method. If it DOES show up, the fields below tell you exactly which
        // subscription fired and for which record.
        print("📬 didReceiveRemoteNotification fired. Raw payload: \(userInfo)")

        // 1. Verify this notification belongs to CloudKit
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)
        print("   CKNotification.notificationType: \(String(describing: notification?.notificationType.rawValue)), subscriptionID: \(notification?.subscriptionID ?? "nil")")

        if let queryNotification = notification as? CKQueryNotification {
            print("   queryNotificationReason: \(queryNotification.queryNotificationReason.rawValue), recordID: \(queryNotification.recordID?.recordName ?? "nil"), recordFields: \(queryNotification.recordFields ?? [:])")
        }

        if notification?.notificationType == .query {
            // 2. Forward the background wake to your manager
            Task {
                await notificationManager?.handleRemoteNotification()
                // 3. Always call completion handler to tell iOS you finished processing
                completionHandler(.newData)
            }
        } else {
            print("   ⚠️ Not a CloudKit query notification — ignoring (noData)")
            completionHandler(.noData)
        }
    }
}
