//
//  TaggoMainApp.swift
//  TaggoMain
//

import SwiftUI

@main
struct TaggoMainApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let dependencies = AppDependencies.live
 
    init() {
        appDelegate.notificationManager = dependencies.notificationManaging
    }
 
    var body: some Scene {
        WindowGroup {
            RootTabView(dependencies: dependencies)
                .onAppear {
                    if appDelegate.notificationManager == nil {
                        appDelegate.notificationManager = dependencies.notificationManaging
                    }
                }
        }
    }
}
