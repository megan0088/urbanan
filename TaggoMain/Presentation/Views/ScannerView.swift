//
//  ScannerView.swift
//  TaggoMain
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
                scannerOverlay
                #endif

            case .loading:
                Color.black.opacity(0.6).ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView().tint(.white).scaleEffect(1.4)
                    Text("Looking up item…")
                        .font(.subheadline).foregroundStyle(.white)
                }

            case .found(let item):
                ScannedItemFlowView(
                    item: item,
                    reportFoundItemUseCase: viewModel.reportFoundItemUseCase,
                    onDismiss: { viewModel.reset() }
                )
                .toolbar(.hidden, for: .tabBar)

            case .failure(let message):
                failureView(message: message)
            }
        }
    }

    // MARK: Scan frame overlay (real device)

    private var scannerOverlay: some View {
        VStack {
            Spacer()
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.white, lineWidth: 3)
                .frame(width: 240, height: 240)
                .background(Color.clear)
            Text("Point at a Taggo QR code")
                .font(.subheadline).foregroundStyle(.white)
                .padding(.top, 16)
            Spacer()
        }
    }

    // MARK: Failure state

    private func failureView(message: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "qrcode.viewfinder")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .foregroundStyle(Color.taggoBlue.opacity(0.4) as Color)

            Text(message)
                .font(.subheadline).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                viewModel.reset()
            } label: {
                Text("Try Again")
                    .font(Font.headline).foregroundStyle(Color.white)
                    .padding(.horizontal, 32).padding(.vertical, 14)
                    .background(Color.taggoBlue)
                    .clipShape(Capsule())
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.taggoBackground)
    }

    // MARK: Simulator debug entry

    #if targetEnvironment(simulator)
    private var simulatorDebugEntry: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "video.slash")
                .font(.system(size: 56))
                .foregroundStyle(Color.taggoBlue.opacity(0.4))
            Text("Simulator — no camera")
                .font(Font.headline).foregroundStyle(.primary)
            Text("Paste an item link below to test the scan flow.")
                .font(.subheadline).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            TextField("https://urbanantaggo.netlify.app/item/<uuid>", text: $debugLinkText)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(.horizontal, TaggoSpacing.horizontalPadding)

            Button {
                Task { await viewModel.handleScannedCode(debugLinkText) }
            } label: {
                Text("Resolve")
                    .font(Font.headline).foregroundStyle(Color.white)
                    .padding(.horizontal, 40).padding(.vertical, 14)
                    .background(debugLinkText.isEmpty ? Color.secondary : Color.taggoBlue)
                    .clipShape(Capsule())
            }
            .disabled(debugLinkText.isEmpty)
            Spacer()
        }
        .background(Color.taggoBackground)
    }
    #endif
}
