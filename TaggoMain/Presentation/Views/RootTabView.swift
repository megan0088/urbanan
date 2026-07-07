//
//  RootTabView.swift
//  TaggoMain
//
//  Created by Xaviero Yamin Loganta on 05/07/26.
//

import Foundation
import SwiftUI

private enum DeepLinkPresentation: Identifiable {
    case owned(Item)
    case found(Item)

    var id: UUID {
        switch self {
        case .owned(let item): return item.id
        case .found(let item): return item.id
        }
    }
}

struct RootTabView: View {
    let dependencies: AppDependencies
    @State private var deepLinkPresentation: DeepLinkPresentation?
    @State private var deepLinkErrorMessage: String?

    var body: some View {
        TabView {
            ItemsTab(dependencies: dependencies)
                .tabItem {
                    Label("Items", systemImage: "rectangle.stack")
                }
            ScanTab(dependencies: dependencies)
                .tabItem {
                    Label("Scan", systemImage: "qrcode.viewfinder")
                }
            InboxTab(dependencies: dependencies)
                .tabItem {
                    Label("Inbox", systemImage: "tray")
                }
        }
        .onOpenURL { url  in
            Task { await handleIncomingLink(url)};
        }
        .onAppear {
            MainInvocationBridge.shared.onURLReceived = { url in
                Task { await handleIncomingLink(url) }
            }
        }
        .sheet(item: $deepLinkPresentation) { presentation in
            switch presentation {
            case .owned(let item):
                ItemDetailView(
                    viewModel: dependencies.makeItemDetailViewModel(item: item),
                    dependencies: dependencies
                )
            case .found(let item):
                ScannedItemFlowView(item: item, reportFoundItemUseCase: dependencies.makeReportFoundItemUseCase(),
                                    onDismiss: { deepLinkPresentation = nil });
            }
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

    private func handleIncomingLink(_ url: URL) async {
        let useCase = dependencies.makeResolveScannedItemUseCase()
        do {
            let item = try await useCase.execute(scannedString: url.absoluteString)
            if item.ownerID == dependencies.currentUserProvider.currentUserID {
                deepLinkPresentation = .owned(item)
            } else {
                deepLinkPresentation = .found(item)
            }
        } catch {
            deepLinkErrorMessage = "That link didn't resolve to a valid item."
        }
    }
}
