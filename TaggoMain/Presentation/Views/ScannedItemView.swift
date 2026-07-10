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
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name)
                                    .font(.title2).fontWeight(.bold)
                                if let desc = item.description, !desc.isEmpty {
                                    Text(desc)
                                        .font(.subheadline).foregroundStyle(.secondary)
                                }
                            }
                            .padding(.top, 20)

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
                        Button(action: onDismiss) {
                            Image(systemName: "qrcode.viewfinder")
                        }
                        .accessibilityLabel("Scan Again")
                    }
                }
            }
        }
    }

    // MARK: Photo

    private var itemPhoto: some View {
        GeometryReader { proxy in
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
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
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

private extension Item {
    static var preview: Item {
        Item(id: UUID(), ownerID: UUID(), name: "Blue Backpack", category: "Bag",
             color: "Navy Blue", description: "A worn navy blue backpack",
             imageData: nil, createdAt: Date(), updatedAt: Date())
    }
}

#Preview {
    ScannedItemView(item: .preview, onReportTapped: {})
}
