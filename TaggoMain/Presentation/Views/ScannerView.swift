//
//  ScannerView.swift
//  urbanan
//
//  Created by Xaviero Yamin Loganta on 06/07/26.
//

import SwiftUI

struct ScannerView: View {
    let dependencies: AppDependencies
    @State private var viewModel: ScanViewModel
    #if targetEnvironment(simulator)
    @State private var debugLinkText = ""
    #endif

    init(viewModel: ScanViewModel, dependencies: AppDependencies) {
        _viewModel = State(initialValue: viewModel)
        self.dependencies = dependencies
    }

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .scanning:
                #if targetEnvironment(simulator)
                simulatorDebugEntry
                #else
                QRCodeCameraView(
                    onCodeScanned: { code in
                        Task { await viewModel.handleScannedCode(code) }
                    },
                    onPermissionDenied: {
                        viewModel.cameraPermissionDenied()
                    }
                )
                .ignoresSafeArea()
                #endif
            case .loading:
                ProgressView("Looking up item…")
            case .owned:
                // Own item — detail sheet is presented below; nothing to show behind it.
                EmptyView()
            case .found(let item):
                ScannedItemFlowView(item: item, reportFoundItemUseCase: viewModel.reportFoundItemUseCase,
                                    onDismiss: {viewModel.reset()} );
            case .failure(let message):
                VStack(spacing: 16) {
                    Text(message).multilineTextAlignment(.center).padding()
                    Button("Try Again") { viewModel.reset() }
                }
            }
        }
        .sheet(item: ownedItemBinding) { item in
            ItemDetailView(
                viewModel: dependencies.makeItemDetailViewModel(item: item),
                dependencies: dependencies
            )
        }
    }

    /// Derives sheet presentation from `viewModel.state` rather than a separate `@State`,
    /// so there's one source of truth. Dismissing the sheet resets the scanner.
    private var ownedItemBinding: Binding<Item?> {
        Binding(
            get: {
                if case .owned(let item) = viewModel.state { return item }
                return nil
            },
            set: { newValue in
                if newValue == nil { viewModel.reset() }
            }
        )
    }

    #if targetEnvironment(simulator)
    private var simulatorDebugEntry: some View {
        VStack(spacing: 16) {
            Text("Simulator has no camera — paste an item link to test.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            TextField("https://urbanantaggo.netlify.app/item/<uuid>", text: $debugLinkText)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            Button("Resolve") {
                Task { await viewModel.handleScannedCode(debugLinkText) }
            }
            .disabled(debugLinkText.isEmpty)
        }
        .padding()
    }
    #endif
}
