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
                invocationURL: URL(string: "https://urbanantaggo.netlify.app/item/C3A2ABFC-CBE2-4BA6-9B08-A8EC94634343")
            )
            .onOpenURL { url in
                print(url)
                invocationURL = url
            }
        }
    }
}
