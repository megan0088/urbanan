//
//  ScannerView.swift
//  urbanan
//
//  Created by Xaviero Yamin Loganta on 06/07/26.
//

import SwiftUI

struct ScannerView: View {
    @State private var viewModel: ScanViewModel
    #if targetEnvironment(simulator)
    @State private var debugLinkText = ""
    #endif

    init(viewModel: ScanViewModel) {
        _viewModel = State(initialValue: viewModel)
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
            case .found(let item):
                ItemDetailView(item: item)
                    .overlay(alignment: .top) {
                        Button("Scan Again") { viewModel.reset() }
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(Capsule())
                            .padding(.top)
                    }
            case .failure(let message):
                VStack(spacing: 16) {
                    Text(message).multilineTextAlignment(.center).padding()
                    Button("Try Again") { viewModel.reset() }
                }
            }
        }
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
