//
//  RootTabView.swift
//  TaggoMain
//
//  Created by Xaviero Yamin Loganta on 05/07/26.
//

import Foundation
import SwiftUI

//struct RootTabView: View {
//    let dependencies: AppDependencies
//    @State private var deepLinkedItem: Item?
//    @State private var deepLinkErrorMessage: String?
//    
//    var body: some View {
//        TabView {
//            ItemsTab(dependencies: dependencies)
//                .tabItem {
//                    Label("Items", systemImage: "rectangle.stack")
//                }
//            ScanTab(dependencies: dependencies)
//                .tabItem {
//                    Label("Scan", systemImage: "qrcode.viewfinder")
//                }
//            InboxTab(dependencies: dependencies)
//                .tabItem {
//                    Label("Inbox", systemImage: "tray")
//                }
//        }
//        .onOpenURL { url  in
//            Task { await handleIncomingLink(url)};
//        }
//        .sheet(item: $deepLinkedItem) { item in
//            ScannedItemFlowView(item: item, reportFoundItemUseCase: dependencies.makeReportFoundItemUseCase(),
//                                onDismiss: {deepLinkedItem = nil});
//        }
//        .alert(
//            "Link Error",
//            isPresented: Binding(
//                get: { deepLinkErrorMessage != nil },
//                set: { if !$0 { deepLinkErrorMessage = nil } }
//            )
//        ) {
//            Button("OK") { deepLinkErrorMessage = nil }
//        } message: {
//            Text(deepLinkErrorMessage ?? "")
//        }
//    }
//    
//    private func handleIncomingLink(_ url: URL) async {
//        let useCase = dependencies.makeResolveScannedItemUseCase()
//        do {
//            deepLinkedItem = try await useCase.execute(scannedString: url.absoluteString)
//        } catch {
//            deepLinkErrorMessage = "That link didn't resolve to a valid item."
//        }
//    }
//}

//MARK Style
//extension Color {
//    static let taggoBlue: Color = .taggoBlue
//    static let taggoBlueLight: Color = .taggoBlueLight
//    static let taggoBackground: Color = .taggoBackground
//}
//
enum TaggoSpacing {
    static let cardCornerRadius: CGFloat = 16
    static let horizontalPadding: CGFloat = 20
}
