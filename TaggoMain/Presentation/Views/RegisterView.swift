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
        Group {
            if case .success(let qrData, let itemLink) = viewModel.state {
                registrationSuccess(qrData: qrData, itemLink: itemLink)
            } else {
                registrationForm
            }
        }
        .navigationTitle(
            (viewModel.state == .idle || viewModel.state == .loading) ? "Add New Item" : "Registered!"
        )
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Registration Form

    private var registrationForm: some View {
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

            bottomBar
        }
    }

    // MARK: Photo picker

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
                                Text("Add Photo")
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
                    await MainActor.run { viewModel.selectedImageData = data }
                }
            }
        }
    }

    // MARK: Form fields

    private var fieldsCard: some View {
        VStack(spacing: 0) {
            FormFieldRow(label: "Name", placeholder: "e.g. Blue Backpack", text: $viewModel.name)
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

    // MARK: Register button

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            Button {
                Task { await viewModel.submit() }
            } label: {
                Group {
                    if viewModel.state == .loading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Register Item").font(Font.headline)
                    }
                }
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.taggoBlue)
                .clipShape(Capsule())
            }
            .disabled(viewModel.state == .loading || viewModel.name.isEmpty)
            .padding(.horizontal, TaggoSpacing.horizontalPadding)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
        }
    }

    // MARK: - Success screen

    private func registrationSuccess(qrData: Data, itemLink: URL) -> some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color.taggoBlue)

            Text("Item Registered!")
                .font(.title2).fontWeight(.bold)
                .padding(.top, 20)

            Text("Save or print your QR code. Stick it on your item so finders can report it.")
                .font(.subheadline).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 8)

            if let img = UIImage(data: qrData) {
                Image(uiImage: img)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.1), radius: 12)
                    .padding(.top, 32)
            }

            Text(itemLink.absoluteString)
                .font(.caption2).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 12)
                .textSelection(.enabled)

            Spacer()

            Button(action: { onFinished?() }) {
                Text("Done")
                    .font(Font.headline).foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.taggoBlue)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, TaggoSpacing.horizontalPadding)
            .padding(.bottom, 40)
        }
        .background(Color.taggoBackground.ignoresSafeArea())
    }
}

// MARK: - Reusable form field row

struct FormFieldRow: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.subheadline).foregroundStyle(.secondary)
                .frame(width: 90, alignment: .leading)
            TextField(placeholder, text: $text)
                .font(.subheadline)
        }
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
        .padding(.vertical, 14)
    }
}
