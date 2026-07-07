//
//  ClipAppDelegate.swift
//  TaggoClip
//
//  Created by Xaviero Yamin Loganta on 07/07/26.
//

import Foundation
import SwiftUI

final class ClipAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        if let userActivity = options.userActivities.first(where: { $0.activityType == NSUserActivityTypeBrowsingWeb }),
           let url = userActivity.webpageURL {
            ClipInvocationBridge.shared.receive(url)
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
        ClipInvocationBridge.shared.receive(url)
        return true
    }
}
