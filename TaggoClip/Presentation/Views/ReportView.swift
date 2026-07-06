//
//  ReportView.swift
//  TaggoClip
//

import SwiftUI
import PhotosUI

struct ReportView: View {
    @State private var viewModel: ReportViewModel
    @State private var photosPickerItem: PhotosPickerItem?
    let invocationURL: URL?

    init(viewModel: ReportViewModel, invocationURL: URL?) {
        _viewModel = State(initialValue: viewModel)
        self.invocationURL = invocationURL
        print("invocationURL: \(invocationURL?.absoluteString ?? "nil")")
    }

    var body: some View {
        NavigationStack {
            content
        }
        .task(id: invocationURL) {
            if let invocationURL {
                await viewModel.handleInvocation(url: invocationURL)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .resolving:
            ProgressView("Loading item…")
        case .found(let item):
            reportForm(for: item)
        case .submitting:
            ProgressView("Submitting…")
        case .success:
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.green)
                Text("Thanks for helping out!")
                    .font(.title2.bold())
                Text("The owner has been notified.")
                    .foregroundStyle(.secondary)
            }
            .padding()
        case .failure(let message):
            Text(message)
                .multilineTextAlignment(.center)
                .padding()
        }
    }

    private func reportForm(for item: Item) -> some View {
        Form {
            Section("You found:") {
                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 150)
                }
                LabeledContent("Name", value: item.name)
                LabeledContent("Category", value: item.category)
                LabeledContent("Color", value: item.color)
            }

            Section("Where did you find it?") {
                TextField("Station", text: $viewModel.station)
                TextField("Note (optional)", text: $viewModel.note)
            }

            Section("Photo (optional)") {
                PhotosPicker(selection: $photosPickerItem, matching: .images) {
                    if let data = viewModel.selectedPhotoData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 120)
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
                    Task { await viewModel.submitReport() }
                }
                .disabled(viewModel.station.isEmpty)
            }
        }
        .navigationTitle(item.name)
    }
}

