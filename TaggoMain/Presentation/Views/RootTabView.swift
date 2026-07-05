//
//  RootTabView.swift
//  TaggoMain
//
//  Created by Xaviero Yamin Loganta on 05/07/26.
//

import Foundation
import SwiftUI

struct RootTabView: View {
    let dependencies: AppDependencies
    @State private var deepLinkedItem: Item?
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
        }
        .onOpenURL { url  in
            Task { await handleIncomingLink(url)};
        }
        .sheet(item: $deepLinkedItem) { item in
            ItemDetailView(item: item)
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
            deepLinkedItem = try await useCase.execute(scannedString: url.absoluteString)
        } catch {
            deepLinkErrorMessage = "That link didn't resolve to a valid item."
        }
    }
}
