//
//  RegisterView.swift
//  TaggoMain
//

import SwiftUI
import PhotosUI

struct RegisterView: View {
    @State private var viewModel: RegisterViewModel
    @State private var photosPickerItem: PhotosPickerItem?
    var onFinished: (() -> Void)?
 
    init(viewModel: RegisterViewModel, onFinished: (() -> Void)? = nil) {
        _viewModel = State(initialValue: viewModel)
        self.onFinished = onFinished
    }
 
    var body: some View {
        Form {
            Section("Photo") {
                let selectedData = viewModel.selectedImageData
                PhotosPicker(selection: $photosPickerItem, matching: .images) {
                    if let data = selectedData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 150)
                    } else {
                        Label("Add Photo", systemImage: "photo.badge.plus")
                    }
                }
                .onChange(of: photosPickerItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            await MainActor.run {
                                viewModel.selectedImageData = data
                            }
                        }
                    }
                }
            }
 
            Section("Item Details") {
                TextField("Name", text: $viewModel.name)
                TextField("Category", text: $viewModel.category)
                TextField("Color", text: $viewModel.color)
                TextField("Description", text: $viewModel.description)
            }
 
            Section {
                Button("Register Item") {
                    Task { await viewModel.submit() }
                }
                .disabled(viewModel.state == .loading)
            }
 
            Section {
                switch viewModel.state {
                case .idle:
                    EmptyView()
                case .loading:
                    ProgressView("Registering…")
                case .success(let qrData):
                    VStack(spacing: 12) {
                        Text("Registered! Print this QR:")
                        if let uiImage = UIImage(data: qrData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 200, height: 200)
                        }
                        Button("Done") { onFinished?() }
                    }
                case .failure(let message):
                    Text(message).foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Register Item")
    }
}
 
