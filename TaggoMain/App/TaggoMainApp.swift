//
//  TaggoMainApp.swift
//  TaggoMain
//

import SwiftUI

@main
struct TaggoMainApp: App {
    private let dependencies = AppDependencies.live
    var body: some Scene {
        WindowGroup {
            RootTabView(dependencies: dependencies)
        }
    }
}
