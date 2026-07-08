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
 
    @State private var deepLinkedItem: Item?
    @State private var deepLinkErrorMessage: String?

    var body: some Scene {
        WindowGroup {
            ItemsTab(dependencies: dependencies)
                .onAppear {
                    if appDelegate.notificationManager == nil {
                        appDelegate.notificationManager = dependencies.notificationManaging
                    }
                }
                .onOpenURL { url in
                    Task { await handleIncomingLink(url) }
                }
                .sheet(item: $deepLinkedItem) { item in
                    ScannedItemFlowView(
                        item: item,
                        reportFoundItemUseCase: dependencies.makeReportFoundItemUseCase(),
                        onDismiss: { deepLinkedItem = nil }
                    )
                }
                .alert(
                    "Link Error",
                    isPresented: Binding(
                        get: { deepLinkErrorMessage != nil },
                        set: { if !$0 { deepLinkErrorMessage = nil } }
                    )
                ) {
                    Button("OK") { deepLinkErrorMessage = nil }
                } message: {
                    Text(deepLinkErrorMessage ?? "")
                }
        }
    }

    private func handleIncomingLink(_ url: URL) async {
        let useCase = dependencies.makeResolveScannedItemUseCase()
        do {
            deepLinkedItem = try await useCase.execute(scannedString: url.absoluteString)
        } catch {
            deepLinkErrorMessage = "That link didn't resolve to a valid item."
        }
    }
}
