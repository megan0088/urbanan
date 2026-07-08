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
    @State private var showQR = false
    @Environment(\.dismiss) private var dismiss

    let dependencies: AppDependencies

    init(viewModel: ItemDetailViewModel, dependencies: AppDependencies) {
        _viewModel = State(initialValue: viewModel)
        self.dependencies = dependencies
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        itemPhoto
                            .padding(.top, 16)

                        Text(viewModel.item.name)
                            .font(.title2).fontWeight(.bold)
                            .padding(.horizontal, TaggoSpacing.horizontalPadding)

                        TipCardView()

                        if case .failure(let message) = viewModel.state {
                            Text(message)
                                .foregroundStyle(.red)
                                .padding(.horizontal, TaggoSpacing.horizontalPadding)
                        }

                        Spacer(minLength: 100)
                    }
                }
                .scrollIndicators(.hidden)
                .background(Color.taggoBackground)

                generateQRButton
            }
            .navigationTitle("Items Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .fontWeight(.medium)
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
                        if viewModel.state == .deleted { dismiss() }
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
            .sheet(isPresented: $showQR) {
                QRCodeSheetView(
                    qrData: viewModel.qrCodeImageData,
                    itemName: viewModel.item.name
                )
            }
        }
    }

    // MARK: Photo with blue border
    private var itemPhoto: some View {
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
        .frame(maxWidth: .infinity)
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius)
                .stroke(Color.taggoBlue, lineWidth: 2)
        )
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
    }

    // MARK: Generate QR button pinned to bottom
    private var generateQRButton: some View {
        VStack(spacing: 0) {
            Divider()
            Button {
                showQR = true
            } label: {
                Text("Generate QR Code")
                    .font(.headline).foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.taggoBlue)
                    .clipShape(Capsule())
            }
            .disabled(viewModel.qrCodeImageData == nil)
            .padding(.horizontal, TaggoSpacing.horizontalPadding)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Tip Card

private struct TipCardView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Color.taggoBlue)
                .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
                Text("Tip").font(.headline)
                Text("Keep your barcode safe. It helps people quickly if they find your belongings.")
                    .font(.subheadline).foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Image(systemName: "person.fill.questionmark")
                .font(.system(size: 36))
                .foregroundStyle(Color.yellow.opacity(0.9))
                .frame(width: 56)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius))
        .shadow(color: .black.opacity(0.06), radius: 8)
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
    }
}

// MARK: - QR Code Sheet

private struct QRCodeSheetView: View {
    @Environment(\.dismiss) private var dismiss
    let qrData: Data?
    let itemName: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                if let data = qrData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 240, height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.1), radius: 12)
                } else {
                    Image(systemName: "qrcode")
                        .font(.system(size: 120))
                        .foregroundStyle(Color.taggoBlue.opacity(0.4))
                }

                Text(itemName)
                    .font(.title3).fontWeight(.semibold)

                Text("Scan this QR code to report finding this item.")
                    .font(.caption).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()
            }
            .navigationTitle("QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
