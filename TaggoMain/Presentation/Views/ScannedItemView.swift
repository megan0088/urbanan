//
//  ScannedItemView.swift
//  TaggoMain
//

import SwiftUI

struct ScannedItemView: View {
    let item: Item
    var onReportTapped: () -> Void
    var onDismiss: (() -> Void)?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        itemPhoto

                        VStack(alignment: .leading, spacing: 16) {
                            Text(item.name)
                                .font(.title2).fontWeight(.bold)
                                .padding(.top, 20)

                            detailsCard

                            infoCard
                        }
                        .padding(.horizontal, TaggoSpacing.horizontalPadding)

                        Spacer(minLength: 120)
                    }
                }
                .scrollIndicators(.hidden)
                .background(Color.taggoBackground)

                bottomBar
            }
            .navigationTitle("Found an Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if let onDismiss {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Scan Again") { onDismiss() }
                    }
                }
            }
        }
    }

    // MARK: Photo

    private var itemPhoto: some View {
        Group {
            if let data = item.imageData, let img = UIImage(data: data) {
                Image(uiImage: img).resizable().scaledToFill()
            } else {
                Color.taggoBlueLight
                    .overlay {
                        Image(systemName: "bag")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                            .foregroundStyle(Color.taggoBlue.opacity(0.4) as Color)
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
        .padding(.top, 16)
    }

    // MARK: Item details

    private var detailsCard: some View {
        VStack(spacing: 0) {
            ItemDetailRow(icon: "tag.circle.fill", label: "Category", value: item.category)
            Divider().padding(.leading, 44)
            ItemDetailRow(icon: "paintpalette.fill", label: "Color", value: item.color)
            if let desc = item.description, !desc.isEmpty {
                Divider().padding(.leading, 44)
                ItemDetailRow(icon: "text.alignleft", label: "Description", value: desc)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius))
    }

    // MARK: Info card

    private var infoCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Color.taggoBlue).font(.title3)
            VStack(alignment: .leading, spacing: 4) {
                Text("Is this your find?").font(.subheadline).fontWeight(.semibold)
                Text("Tap below to let the owner know their item has been found.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color.taggoBlueLight.opacity(0.4) as Color)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: Bottom bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            Button(action: onReportTapped) {
                Text("I Found This Item")
                    .font(Font.headline)
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.taggoBlue)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, TaggoSpacing.horizontalPadding)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Detail row

private struct ItemDetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.taggoBlue)
                .font(.title3)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.caption).foregroundStyle(.secondary)
                Text(value).font(.subheadline).fontWeight(.medium)
            }
            Spacer()
        }
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
        .padding(.vertical, 12)
    }
}
