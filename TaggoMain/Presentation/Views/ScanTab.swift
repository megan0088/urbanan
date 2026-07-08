//
//  ScanTab.swift
//  TaggoMain
//

import SwiftUI

struct ScanTab: View {
    @State private var viewModel: ScanViewModel

    init(dependencies: AppDependencies) {
        _viewModel = State(initialValue: dependencies.makeScanViewModel())
    }

    var body: some View {
        NavigationStack {
            ScannerView(viewModel: viewModel)
                .navigationTitle("Scan")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}
