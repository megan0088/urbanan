//
//  EditItemView.swift
//  TaggoMain
//
//  Created by Xaviero Yamin Loganta on 06/07/26.
//

import SwiftUI
import PhotosUI

struct EditItemView: View {
    @State private var viewModel: EditItemViewModel
    @State private var photosPickerItem: PhotosPickerItem?
    @Environment(\.dismiss) private var dismiss
    var onSaved: (Item) -> Void

    init(viewModel: EditItemViewModel, onSaved: @escaping (Item) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    let data = viewModel.selectedImageData
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
                                viewModel.selectedImageData = data
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

                if case .failure(let message) = viewModel.state {
                    Text(message).foregroundStyle(.red)
                }
            }
            .navigationTitle("Edit Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            if let updated = await viewModel.save() {
                                onSaved(updated)
                            }
                        }
                    }
                    .disabled(viewModel.state == .saving)
                }
            }
        }
    }
}
