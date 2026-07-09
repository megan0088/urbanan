//
//  ItemDetailView.swift
//  TaggoMain
//

import Foundation
import SwiftUI

struct ItemDetailView: View {
    @State private var viewModel: ItemDetailViewModel
    @State private var isPresentingEdit = false
    @State private var isPresentingDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss

    let dependencies: AppDependencies
    var onItemModified: (() -> Void)?

    init(viewModel: ItemDetailViewModel, dependencies: AppDependencies, onItemModified: (() -> Void)? = nil) {
        _viewModel = State(initialValue: viewModel)
        self.dependencies = dependencies
        self.onItemModified = onItemModified
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    itemPhoto
                        .padding(.top, 16)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.item.name)
                            .font(.title2).fontWeight(.bold)
                        if let desc = viewModel.item.description, !desc.isEmpty {
                            Text(desc)
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, TaggoSpacing.horizontalPadding)

                    qrCodeCard

                    if case .failure(let message) = viewModel.state {
                        Text(message)
                            .foregroundStyle(.red)
                            .padding(.horizontal, TaggoSpacing.horizontalPadding)
                    }

                    Spacer(minLength: 40)
                }
            }
            .scrollIndicators(.hidden)
            .background(Color.taggoBackground)
            .navigationDestination(isPresented: Binding(
                get: { viewModel.qrSaved },
                set: { if !$0 { viewModel.dismissQRSavedConfirmation() } }
            )) {
                QRDownloadSuccessView()
            }
            .navigationTitle("Items Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left").fontWeight(.medium)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Edit") { isPresentingEdit = true }
                        Button("Delete", role: .destructive) {
                            isPresentingDeleteConfirmation = true
                        }
                    } label: {
                        Image(systemName: "square.and.pencil")
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
                            onItemModified?()
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
                        onItemModified?()
                        isPresentingEdit = false
                    }
                )
            }
        }
    }

    // MARK: - Item Photo

    private var itemPhoto: some View {
        GeometryReader { proxy in
            Group {
                if let data = viewModel.item.imageData, let img = UIImage(data: data) {
                    Image(uiImage: img).resizable().scaledToFill()
                } else {
                    Color.taggoBlueLight
                        .overlay {
                            Image(systemName: "photo")
                                .font(.system(size: 48))
                                .foregroundStyle(Color.taggoBlue.opacity(0.4))
                        }
                }
            }
            .frame(width: proxy.size.width).frame(height: proxy.size.height)
            .clipped()

            
        }
        .clipShape(RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius))
        .overlay(RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius)
                    .stroke(Color.taggoBlue, lineWidth: 2))
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
        .frame(maxWidth: .infinity).frame(height: 260);
    }

    // MARK: - QR Code Card (inline)

    private var qrCodeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Your QR Code")
                .font(.headline)

            if let data = viewModel.qrCodeImageData, let img = UIImage(data: data) {
                HStack(alignment: .top, spacing: 14) {
                    Image(uiImage: img)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 96, height: 96)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Text("Anyone who finds your item can scan this QR code to notify you through the app.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button {
                    Task { await viewModel.saveQRCodeToPhotos() }
                } label: {
                    Label("Download QR Code", systemImage: "arrow.down.to.line")
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color(red: 0.996, green: 0.788, blue: 0.122))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // Copy to clipboard
                Button {
                    viewModel.copyQRCodeToClipboard()
                } label: {
                    Label(
                        viewModel.qrCopied ? "Copied!" : "Copy QR Code",
                        systemImage: viewModel.qrCopied ? "checkmark" : "doc.on.doc"
                    )
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundStyle(Color.taggoBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color.taggoBlueLight.opacity(0.5) as Color)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

            } else {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(minHeight: 80)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius)
                .strokeBorder(Color.taggoBlue, style: StrokeStyle(lineWidth: 1.5, dash: [6]))
        )
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
        .alert("Permission Required", isPresented: Binding(
            get: { viewModel.qrSaveError },
            set: { if !$0 { viewModel.dismissQRSaveError() } }
        )) {
            Button("OK") {}
        } message: {
            Text("Please allow Photos access in Settings to save the QR code.")
        }
    }
}

#Preview {
    let item = Item(id: UUID(), ownerID: UUID(), name: "Tas Mania Mantap", category: "Bag",
                    color: "Black", description: "Tas jinjing warna hitam sudah agak pudar dengan gantungan kunci karakter favorit",
                    imageData: nil, createdAt: Date(), updatedAt: Date())
    let deps = AppDependencies.live
    NavigationStack {
        ItemDetailView(viewModel: deps.makeItemDetailViewModel(item: item), dependencies: deps)
    }
}
