//
//  TaggoClipApp.swift
//  TaggoClip
//

import SwiftUI

import SwiftUI

@main
struct TaggoClipApp: App {
    private let dependencies = ClipDependencies.live
    @State private var invocationURL: URL?

    var body: some Scene {
        WindowGroup {
            ReportView(
                viewModel: ReportViewModel(
                    resolveScannedItemUseCase: dependencies.makeResolveScannedItemUseCase(),
                    reportFoundItemUseCase: dependencies.makeReportFoundItemUseCase()
                ),
                invocationURL: invocationURL
            )
            .onOpenURL { url in
//                print("GRRRR \(url)")
                invocationURL = url;
            }
            #if DEBUG
            .task {
                if invocationURL == nil {
                    try? await Task.sleep(for: .seconds(1))
                    if invocationURL == nil {
                        invocationURL = URL(string: "https://urbananTaggo.netlify.app/item/11AA848B-2CF5-4B97-BD90-58673DD46350")
                    }
                }
            }
            #endif
        }
    }
}
