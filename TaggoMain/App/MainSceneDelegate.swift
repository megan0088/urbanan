//
//  MainSceneDelegate.swift
//  TaggoMain
//

import UIKit

final class MainSceneDelegate: NSObject, UIWindowSceneDelegate {
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        print("🔗 MainSceneDelegate.willConnectTo fired. userActivities: \(connectionOptions.userActivities.map { ($0.activityType, $0.webpageURL?.absoluteString ?? "nil") })")
        if let userActivity = connectionOptions.userActivities.first(where: { $0.activityType == NSUserActivityTypeBrowsingWeb }),
           let url = userActivity.webpageURL {
            print("🔗 MainSceneDelegate.willConnectTo: capturing cold-launch URL \(url.absoluteString)")
            MainInvocationBridge.shared.receive(url)
        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        print("🔗 MainSceneDelegate.continue fired. activityType: \(userActivity.activityType), webpageURL: \(userActivity.webpageURL?.absoluteString ?? "nil")")
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return
        }
        print("🔗 MainSceneDelegate.continue: capturing warm-launch URL \(url.absoluteString)")
        MainInvocationBridge.shared.receive(url)
    }
}
