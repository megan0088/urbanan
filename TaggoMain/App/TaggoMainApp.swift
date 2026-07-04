//
//  TaggoMainApp.swift
//  TaggoMain
//

import SwiftUI

@main
struct TaggoMainApp: App {
    var body: some Scene {
        WindowGroup {
            let cloudKitManager = CloudKitManager()
            let qrManager = QRManager()
            let currentUserProvider = CurrentUserProvider()
            let useCase = RegisterItemUseCase(
                cloudKitManager: cloudKitManager,
                qrManager: qrManager,
                currentUserProvider: currentUserProvider
            )
            RegisterView(viewModel: RegisterViewModel(registerItemUseCase: useCase))
        }
    }
}
