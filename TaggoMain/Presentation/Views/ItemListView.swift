//
//  ItemListView.swift
//  TaggoMain
//

import SwiftUI

/// Reads the true device safe area directly from the key window rather than
/// SwiftUI's ambient safe-area environment — `.safeAreaPadding`/`GeometryReader`
/// both read a value that gets skewed by ancestors already ignoring/reserving
/// safe area (e.g. a hidden-background nav bar still reserving its own height),
/// which made the header's top clearance unreliable.
private var keyWindowTopSafeAreaInset: CGFloat {
    UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.safeAreaInsets.top ?? 0
}

struct ItemListView: View {
    let dependencies: AppDependencies
    @State private var viewModel: ItemListViewModel
    @State private var inboxViewModel: InboxViewModel
    @State private var selectedItem: Item?
    @State private var selectedPendingReport: FoundReport?
    @State private var itemWasModified = false
    var onAddTapped: () -> Void
    var onScanTapped: () -> Void
    var onBellTapped: () -> Void

    init(
        dependencies: AppDependencies,
        viewModel: ItemListViewModel,
        inboxViewModel: InboxViewModel,
        onAddTapped: @escaping () -> Void,
        onScanTapped: @escaping () -> Void,
        onBellTapped: @escaping () -> Void
    ) {
        self.dependencies = dependencies
        _viewModel = State(initialValue: viewModel)
        _inboxViewModel = State(initialValue: inboxViewModel)
        self.onAddTapped = onAddTapped
        self.onScanTapped = onScanTapped
        self.onBellTapped = onBellTapped
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    HomeHeaderView(
                        hasUnread: inboxViewModel.hasUnread,
                        hasItems: !viewModel.items.isEmpty,
                        onBellTapped: onBellTapped
                    )

                    if let latest = inboxViewModel.pendingReports.first {
                        PendingReportHighlightView(
                            report: latest,
                            item: viewModel.item(withID: latest.itemID),
                            additionalCount: inboxViewModel.pendingReports.count - 1,
                            onTapped: {
                                selectedPendingReport = latest
                                Task { await inboxViewModel.markAsRead(latest) }
                            },
                            onMoreTapped: onBellTapped
                        )
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        Text("Your Items")
                            .font(.title3).fontWeight(.bold)
                            .padding(.horizontal, TaggoSpacing.horizontalPadding)
                            .padding(.top, 20)
                            .padding(.bottom, 12)

                        itemsContent
                    }
                }
            }
            .background(Color.taggoBackground)
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .top)
            .padding(.bottom, 80)

            HomeBottomBar(searchText: $viewModel.searchText, onAddTapped: onAddTapped, onScanTapped: onScanTapped)
        }
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
        .sheet(item: $selectedItem, onDismiss: {
            if itemWasModified {
                itemWasModified = false
                Task { await viewModel.load() }
            }
        }) { item in
            ItemDetailView(
                viewModel: dependencies.makeItemDetailViewModel(item: item),
                dependencies: dependencies,
                onItemModified: { itemWasModified = true }
            )
        }
        .sheet(item: $selectedPendingReport) { report in
            ReportDetailView(report: report, viewModel: inboxViewModel, item: viewModel.item(withID: report.itemID))
        }
    }

    @ViewBuilder
    private var itemsContent: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, 80)

        case .loaded:
            if viewModel.filteredItems.isEmpty {
                EmptyItemsView()
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.filteredItems) { item in
                        Button {
                            selectedItem = item
                        } label: {
                            ItemListRowView(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius))
                .padding(.horizontal, TaggoSpacing.horizontalPadding)
            }

        case .failure(let message):
            Text(message)
                .foregroundStyle(.red)
                .padding()
        }
    }
}

// MARK: - Blue Header

private struct HomeHeaderView: View {
    var hasUnread: Bool
    var hasItems: Bool
    var onBellTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                Button(action: onBellTapped) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .font(.system(size: 20, weight: .medium))
                            .padding(20)
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(.white.opacity(0.2))
                            .clipShape(Circle())

                        if hasUnread {
                            Circle()
                                .fill(Color(red: 1, green: 0.4, blue: 0.35))
                                .frame(width: 12, height: 12)
                                .offset(x: 2, y: -2)
                        }
                    }
                }
            }

            Text("Hi, Commuters!")
                .font(.largeTitle).fontWeight(.bold)
                .foregroundStyle(.white)

            Text(hasItems
                 ? "Keep track of everything you carry."
                 : "Track all the items you've saved.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
        .padding(.bottom, 24)
        .padding(.top, keyWindowTopSafeAreaInset + 20)
        .background(
            UnevenRoundedRectangle(bottomTrailingRadius: 75)
                .fill(Color.taggoBlue)
                .ignoresSafeArea(edges: .top)
        )
    }
}

// MARK: - Pending Report Highlight

private struct PendingReportHighlightView: View {
    let report: FoundReport
    let item: Item?
    let additionalCount: Int
    var onTapped: () -> Void
    var onMoreTapped: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if additionalCount > 0 {
                RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius)
                    .fill(Color.orange.opacity(0.15))
                    .padding(.horizontal, TaggoSpacing.horizontalPadding + 10)
                    .offset(y: 10)
            }

            Button(action: onTapped) {
                HStack(spacing: 12) {
                    photoThumbnail

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                            Text("Item Found!")
                                .font(.subheadline).fontWeight(.bold)
                                .foregroundStyle(Color(.label))
                        }

                        Text(item.map { "\($0.name) reported at \(report.station)" }
                             ?? "Reported found at \(report.station)")
                            .font(.caption)
                            .foregroundStyle(Color(.secondaryLabel))
                            .lineLimit(1)

                        Text(report.reportedAt, format: .relative(presentation: .named))
                            .font(.caption2)
                            .foregroundStyle(Color(.tertiaryLabel))
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.caption).fontWeight(.semibold)
                        .foregroundStyle(.tertiary)
                }
                .padding(12)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius)
                        .stroke(Color.orange.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
            }
            .buttonStyle(.plain)

            if additionalCount > 0 {
                Button(action: onMoreTapped) {
                    Text("+\(additionalCount)")
                        .font(.caption2).fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 9).padding(.vertical, 4)
                        .background(Color.taggoBlue)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color(.systemBackground), lineWidth: 2))
                }
                .offset(x: -10, y: 10)
            }
        }
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
        .padding(.top, 16)
    }

    @ViewBuilder
    private var photoThumbnail: some View {
        Group {
            if let data = item?.imageData, let img = UIImage(data: data) {
                Image(uiImage: img).resizable().scaledToFill()
            } else {
                Color.orange.opacity(0.15)
                    .overlay {
                        Image(systemName: "shippingbox.fill")
                            .foregroundStyle(.orange)
                    }
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Empty State

private struct EmptyItemsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            Image("ibuibu")
                .resizable()
                .scaledToFit()
                .frame(height: 180)

            Text("Let's add your first item and\nkeep your belongings easy to identify!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - List Row

private struct ItemListRowView: View {
    let item: Item

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                Group {
                    if let data = item.imageData, let img = UIImage(data: data) {
                        Image(uiImage: img).resizable().scaledToFill()
                    } else {
                        Color.taggoBlueLight
                            .overlay {
                                Image(systemName: "bag")
                                    .foregroundStyle(Color.taggoBlue.opacity(0.5))
                            }
                    }
                }
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name).font(.headline)
                    Text("Added \(item.createdAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption).foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption).fontWeight(.semibold)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, TaggoSpacing.horizontalPadding)
            .padding(.vertical, 14)
            .contentShape(Rectangle())

            Divider()
                .padding(.leading, 56 + 14 + TaggoSpacing.horizontalPadding)
        }
    }
}

// MARK: - Bottom Search Bar + Add Button

private struct HomeBottomBar: View {
    @Binding var searchText: String
    var onAddTapped: () -> Void
    var onScanTapped: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search item name", text: $searchText)
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                } else {
                    Image(systemName: "mic").foregroundStyle(.secondary)
                }
            }
            .padding(12)
            .background(Color(.systemBackground))
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 8, y: 2)

            Button(action: onScanTapped) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.title2).fontWeight(.semibold)
                    .foregroundStyle(Color.taggoBlue)
                    .frame(width: 52, height: 52)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.taggoBlue.opacity(0.3), lineWidth: 1.5))
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
            }

            Button(action: onAddTapped) {
                Image(systemName: "plus")
                    .font(.title2).fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Color.taggoBlue)
                    .clipShape(Circle())
                    .shadow(color: Color.taggoBlue.opacity(0.4), radius: 8, y: 4)
            }
        }
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
        .padding(.bottom, 24)
        .padding(.top, 12)
        .background(Color.taggoBackground.opacity(0.95).ignoresSafeArea())
    }
}

#Preview("Full View") {
    let deps = AppDependencies.live
    ItemListView(
        dependencies: deps,
        viewModel: deps.makeItemListViewModel(),
        inboxViewModel: deps.makeInboxViewModel(),
        onAddTapped: {},
        onScanTapped: {},
        onBellTapped: {}
    )
}

#Preview("Item Row") {
    let items: [(String, String, String)] = [
        ("Blue Backpack", "Bag", "Navy Blue"),
        ("AirPods Pro", "Electronics", "White"),
        ("KTP / ID Card", "Document", "Blue"),
        ("Dompet Kulit", "Wallet", "Brown"),
    ]
    VStack(spacing: 0) {
        ForEach(items, id: \.0) { name, category, color in
            ItemListRowView(item: Item(
                id: UUID(), ownerID: UUID(), name: name, category: category,
                color: color, description: nil, imageData: nil,
                createdAt: Date(), updatedAt: Date()
            ))
        }
    }
    .background(Color(.systemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Header — unread") {
    HomeHeaderView(hasUnread: true, hasItems: true, onBellTapped: {})
}

#Preview("Empty State") {
    EmptyItemsView()
}

#Preview("Pending Highlight — single") {
    PendingReportHighlightView(
        report: FoundReport(
            id: UUID(), itemID: UUID(), station: "Stasiun Gambir", note: nil, photoData: nil,
            status: .pending, isRead: false, reportedAt: Date().addingTimeInterval(-300), claimedAt: nil
        ),
        item: Item(id: UUID(), ownerID: UUID(), name: "Blue Backpack", category: "Bag",
                   color: "Navy Blue", description: nil, imageData: nil,
                   createdAt: Date(), updatedAt: Date()),
        additionalCount: 0,
        onTapped: {},
        onMoreTapped: {}
    )
    .padding(.top, 16)
    .background(Color.taggoBackground)
}

#Preview("Pending Highlight — stacked") {
    PendingReportHighlightView(
        report: FoundReport(
            id: UUID(), itemID: UUID(), station: "Stasiun Gambir", note: nil, photoData: nil,
            status: .pending, isRead: false, reportedAt: Date().addingTimeInterval(-300), claimedAt: nil
        ),
        item: Item(id: UUID(), ownerID: UUID(), name: "Blue Backpack", category: "Bag",
                   color: "Navy Blue", description: nil, imageData: nil,
                   createdAt: Date(), updatedAt: Date()),
        additionalCount: 2,
        onTapped: {},
        onMoreTapped: {}
    )
    .padding(.top, 16)
    .background(Color.taggoBackground)
}

