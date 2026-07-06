//
//  ItemDetailView.swift
//  TaggoMain
//
//  Created by Xaviero Yamin Loganta on 05/07/26.
//

import Foundation
import SwiftUI

struct ItemDetailView: View {
    @State private var viewModel: ItemDetailViewModel
    @State private var isPresentingEdit = false
    @State private var isPresentingDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss
 
    let dependencies: AppDependencies
 
    init(viewModel: ItemDetailViewModel, dependencies: AppDependencies) {
        _viewModel = State(initialValue: viewModel)
        self.dependencies = dependencies
    }
 
    var body: some View {
        NavigationStack {
            Form {
                if let imageData = viewModel.item.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                }
                LabeledContent("Name", value: viewModel.item.name)
                LabeledContent("Category", value: viewModel.item.category)
                LabeledContent("Color", value: viewModel.item.color)
                if let description = viewModel.item.description, !description.isEmpty {
                    LabeledContent("Description", value: description)
                }
                LabeledContent(
                    "Registered",
                    value: viewModel.item.createdAt.formatted(date: .abbreviated, time: .shortened)
                )
 
                Section("QR Code") {
                    if let qrData = viewModel.qrCodeImageData, let uiImage = UIImage(data: qrData) {
                        HStack {
                            Spacer()
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 200, height: 200)
                            Spacer()
                        }
                    }
                }
 
                if case .failure(let message) = viewModel.state {
                    Text(message).foregroundStyle(.red)
                }
            }
            .navigationTitle(viewModel.item.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Edit") { isPresentingEdit = true }
                        Button("Delete", role: .destructive) {
                            isPresentingDeleteConfirmation = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .disabled(viewModel.state == .working)
                }
            }
            .confirmationDialog(
                "Delete this item?",
                isPresented: $isPresentingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.delete()
                        if viewModel.state == .deleted {
                            dismiss()
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $isPresentingEdit) {
                EditItemView(
                    viewModel: dependencies.makeEditItemViewModel(item: viewModel.item),
                    onSaved: { updated in
                        viewModel.applyEdit(updated)
                        isPresentingEdit = false
                    }
                )
            }
        }
    }
}
