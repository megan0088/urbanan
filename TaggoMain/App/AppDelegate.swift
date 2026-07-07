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
        if let userActivity = options.userActivities.first(where: { $0.activityType == NSUserActivityTypeBrowsingWeb }),
           let url = userActivity.webpageURL {
            MainInvocationBridge.shared.receive(url)
        }
        return UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }
        MainInvocationBridge.shared.receive(url)
        return true
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
