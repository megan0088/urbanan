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
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }

    // MARK: Photo

    private var photoSection: some View {
        let imageData = viewModel.selectedImageData
        let blue = Color("TaggoBlue")
        let blueLight = Color("TaggoBlueLight")
        return PhotosPicker(selection: $photosPickerItem, matching: .images) {
            GeometryReader { proxy in
                Group {
                    if let data = imageData, let img = UIImage(data: data) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                    } else {
                        blueLight
                            .overlay {
                                VStack(spacing: 10) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 44))
                                        .foregroundStyle(blue.opacity(0.6))
                                    Text("Change Photo")
                                        .font(.subheadline)
                                        .foregroundStyle(blue)
                                }
                            }
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(blue.opacity(0.3), lineWidth: 1.5)
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
            FormFieldRow(label: "Name*", placeholder: "Item name", text: $viewModel.name)
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
                .background(viewModel.isNameValid ? Color.taggoBlue : Color.secondary)
                .clipShape(Capsule())
            }
            .disabled(viewModel.state == .saving || !viewModel.isNameValid)
            .padding(.horizontal, TaggoSpacing.horizontalPadding)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
        }
    }
}

#Preview {
    let item = Item(id: UUID(), ownerID: UUID(), name: "Blue Backpack", category: "Bag",
                    color: "Navy Blue", description: nil, imageData: nil,
                    createdAt: Date(), updatedAt: Date())
    EditItemView(viewModel: AppDependencies.live.makeEditItemViewModel(item: item), onSaved: { _ in })
}
