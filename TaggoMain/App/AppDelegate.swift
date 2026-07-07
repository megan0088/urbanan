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
        // Earliest possible hook — fires before configurationForConnecting. If
        // .userActivityDictionary shows up here but configurationForConnecting still logs
        // an empty userActivities array, the activity is getting lost between these two
        // calls rather than never being delivered at all.
        print("🚀 didFinishLaunchingWithOptions fired. launchOptions: \(String(describing: launchOptions))")
        if let activityDict = launchOptions?[.userActivityDictionary] {
            print("🚀 launchOptions contains .userActivityDictionary: \(activityDict)")
        }

        application.registerForRemoteNotifications()
        Task {
            do {
                let granted = try await notificationManager?.requestAuthorization()
                print("Notification authorization granted: \(String(describing: granted))")
            } catch {
                print("Notification authorization request failed: \(error)")
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
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Delegate class is the important part here — this is what actually gets scene-level
        // continuation events (willConnectTo / continue userActivity) delivered reliably,
        // instead of relying on SwiftUI's implicit scene delegate + .onOpenURL bridging,
        // which testing showed never fires for warm-launch Universal Link taps.
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = MainSceneDelegate.self
        return configuration
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("📬 didReceiveRemoteNotification fired. Raw payload: \(userInfo)")

        // 1. Verify this notification belongs to CloudKit
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)
        print("   CKNotification.notificationType: \(String(describing: notification?.notificationType.rawValue)), subscriptionID: \(notification?.subscriptionID ?? "nil")")

        if let queryNotification = notification as? CKQueryNotification {
            print("   queryNotificationReason: \(queryNotification.queryNotificationReason.rawValue), recordID: \(queryNotification.recordID?.recordName ?? "nil"), recordFields: \(queryNotification.recordFields ?? [:])")
        }

        if notification?.notificationType == .query {
            Task {
                await notificationManager?.handleRemoteNotification()
                completionHandler(.newData)
            }
        } else {
            print("   ⚠️ Not a CloudKit query notification — ignoring (noData)")
            completionHandler(.noData)
        }
    }
}
