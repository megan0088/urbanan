//
//  ScanTab.swift
//  urbanan
//
//  Created by Xaviero Yamin Loganta on 06/07/26.
//

import SwiftUI
 
struct ScanTab: View {
    let dependencies: AppDependencies
    @State private var viewModel: ScanViewModel

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _viewModel = State(initialValue: dependencies.makeScanViewModel())
    }

    var body: some View {
        NavigationStack {
            ScannerView(viewModel: viewModel, dependencies: dependencies)
                .navigationTitle("Scan")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
