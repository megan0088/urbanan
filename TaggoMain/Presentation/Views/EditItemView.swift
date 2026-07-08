//
//  EditItemView.swift
//  TaggoMain
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
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 16) {
                        photoSection
                        fieldsCard
                        if case .failure(let msg) = viewModel.state {
                            Text(msg)
                                .font(.caption).foregroundStyle(.red)
                                .padding(.horizontal, TaggoSpacing.horizontalPadding)
                        }
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 16)
                }
                .scrollIndicators(.hidden)
                .background(Color.taggoBackground)

                saveBar
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: Photo

    private var photoSection: some View {
        PhotosPicker(selection: $photosPickerItem, matching: .images) {
            Group {
                if let data = viewModel.selectedImageData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.taggoBlueLight
                        .overlay {
                            VStack(spacing: 10) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 44))
                                    .foregroundStyle(Color.taggoBlue.opacity(0.6) as Color)
                                Text("Change Photo")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.taggoBlue)
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius)
                    .stroke(Color.taggoBlue.opacity(0.3) as Color, lineWidth: 1.5)
            )
        }
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
        .onChange(of: photosPickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    viewModel.selectedImageData = data
                }
            }
        }
    }

    // MARK: Fields

    private var fieldsCard: some View {
        VStack(spacing: 0) {
            FormFieldRow(label: "Name", placeholder: "Item name", text: $viewModel.name)
            Divider().padding(.leading, TaggoSpacing.horizontalPadding)
            FormFieldRow(label: "Category", placeholder: "e.g. Bag, Electronics", text: $viewModel.category)
            Divider().padding(.leading, TaggoSpacing.horizontalPadding)
            FormFieldRow(label: "Color", placeholder: "e.g. Navy Blue", text: $viewModel.color)
            Divider().padding(.leading, TaggoSpacing.horizontalPadding)
            FormFieldRow(label: "Description", placeholder: "Optional details", text: $viewModel.description)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius))
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
    }

    // MARK: Save bar

    private var saveBar: some View {
        VStack(spacing: 0) {
            Divider()
            Button {
                Task {
                    if let updated = await viewModel.save() {
                        onSaved(updated)
                    }
                }
            } label: {
                Group {
                    if viewModel.state == .saving {
                        ProgressView().tint(.white)
                    } else {
                        Text("Save Changes").font(Font.headline)
                    }
                }
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.taggoBlue)
                .clipShape(Capsule())
            }
            .disabled(viewModel.state == .saving || viewModel.name.isEmpty)
            .padding(.horizontal, TaggoSpacing.horizontalPadding)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
        }
    }
}
