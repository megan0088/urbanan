//
//  ItemListView.swift
//  TaggoMain
//

import SwiftUI

struct ItemListView: View {
    let dependencies: AppDependencies
    @State private var viewModel: ItemListViewModel
    @State private var inboxViewModel: InboxViewModel
    @State private var selectedItem: Item?
    @State private var searchText = ""
    @State private var showInbox = false
    var onAddTapped: () -> Void

    init(dependencies: AppDependencies, viewModel: ItemListViewModel, onAddTapped: @escaping () -> Void) {
        self.dependencies = dependencies
        _viewModel = State(initialValue: viewModel)
        _inboxViewModel = State(initialValue: dependencies.makeInboxViewModel())
        self.onAddTapped = onAddTapped
    }

    private var hasUnread: Bool {
        if case .loaded(let reports) = inboxViewModel.state {
            return reports.contains { !$0.isRead }
        }
        return false
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    HomeHeaderView(hasUnread: hasUnread, onBellTapped: { showInbox = true })

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

            HomeBottomBar(searchText: $searchText, onAddTapped: onAddTapped)
        }
        .task {
            await viewModel.load()
        }
        .task {
            await inboxViewModel.load()
        }
        .task {
            await inboxViewModel.observeFoundReportEvents()
        }
        .refreshable {
            await viewModel.load()
        }
        .sheet(item: $selectedItem, onDismiss: {
            Task { await viewModel.load() }
        }) { item in
            ItemDetailView(
                viewModel: dependencies.makeItemDetailViewModel(item: item),
                dependencies: dependencies
            )
        }
        .sheet(isPresented: $showInbox) {
            InboxView(viewModel: inboxViewModel, dependencies: dependencies)
        }
    }

    @ViewBuilder
    private var itemsContent: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, 80)

        case .loaded(let items):
            let filtered = searchText.isEmpty
                ? items
                : items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }

            if filtered.isEmpty {
                EmptyItemsView()
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(filtered) { item in
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
    var onBellTapped: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.taggoBlue
                .clipShape(UnevenRoundedRectangle(
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 30
                ))

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: onBellTapped) {
                        Image(systemName: hasUnread ? "bell.fill" : "bell")
                            .foregroundStyle(Color.taggoBlue)
                            .font(.system(size: 18, weight: .medium))
                            .padding(20)
                            .background(.white)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, TaggoSpacing.horizontalPadding)
                .padding(.top, 24)

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    Text("Hi, Commuters!")
                        .font(.largeTitle).fontWeight(.bold)
                        .foregroundStyle(.white)
                    Text("Track all the items you've saved.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, TaggoSpacing.horizontalPadding)
                .padding(.bottom, 28)
            }
        }
        .frame(height: 200)
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

#Preview {
    let deps = AppDependencies.live
    ItemListView(dependencies: deps, viewModel: deps.makeItemListViewModel(), onAddTapped: {})
}

