//
//  ReportFormView.swift
//  TaggoMain
//
//  Created by Xaviero Yamin Loganta on 06/07/26.
//

import SwiftUI
import PhotosUI

struct ReportFormView: View {
    @State private var viewModel: ReportFormViewModel
    @State private var photosPickerItem: PhotosPickerItem?
    var onFinished: (() -> Void)?

    init(viewModel: ReportFormViewModel, onFinished: (() -> Void)? = nil) {
        _viewModel = State(initialValue: viewModel)
        self.onFinished = onFinished
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Where did you find it?") {
                    TextField("Station", text: $viewModel.station)
                    TextField("Note (optional)", text: $viewModel.note)
                }

                Section("Photo (optional)") {
                    let data = viewModel.selectedPhotoData
                    PhotosPicker(selection: $photosPickerItem, matching: .images) {
                        if let data = data, let uiImage = UIImage(data: data) {
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
                                viewModel.selectedPhotoData = data
                            }
                        }
                    }
                }

                Section {
                    Button("Submit Report") {
                        Task { await viewModel.submit() }
                    }
                    .disabled(viewModel.state == .submitting || viewModel.station.isEmpty)
                }

                switch viewModel.state {
                case .idle, .submitting:
                    if viewModel.state == .submitting {
                        ProgressView("Submitting…")
                    }
                case .success:
                    VStack(spacing: 12) {
                        Text("Thanks! The owner has been notified.")
                        Button("Done") { onFinished?() }
                    }
                case .failure(let message):
                    Text(message).foregroundStyle(.red)
                }
            }
            .navigationTitle("Report Found Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onFinished?() }
                }
            }
        }
    }
}
