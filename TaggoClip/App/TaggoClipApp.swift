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
                        invocationURL = URL(string: "https://urbanantaggo.netlify.app/item/F4138F1B-7087-4628-99F0-20D467CF0B24")
                    }
                }
            }
            #endif
        }
    }
}
