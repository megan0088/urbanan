//
//  InboxView.swift
//  TaggoMain
//

import SwiftUI

struct InboxView: View {
    @State private var viewModel: InboxViewModel
    @State private var itemListViewModel: ItemListViewModel
    @State private var selectedReport: FoundReport?

    init(viewModel: InboxViewModel, dependencies: AppDependencies) {
        _viewModel = State(initialValue: viewModel)
        _itemListViewModel = State(initialValue: dependencies.makeItemListViewModel())
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .failure:
                #if DEBUG
                reportList(InboxSeeder.reports)
                #else
                InboxEmptyView(message: "Failed to load notifications.", isError: true)
                #endif

            case .loaded(let reports):
                let display: [FoundReport] = {
                    #if DEBUG
                    return reports.isEmpty ? InboxSeeder.reports : reports
                    #else
                    return reports
                    #endif
                }()
                if display.isEmpty {
                    InboxEmptyView(message: "You got no notification yet", isError: false)
                } else {
                    reportList(display)
                }
            }
        }
        .navigationTitle("Notification")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.taggoBackground)
        .task {
            await viewModel.load()
            await itemListViewModel.load()
        }
        .task {
            await viewModel.observeFoundReportEvents()
        }
        .refreshable {
            await viewModel.load()
            await itemListViewModel.load()
        }
        .sheet(item: $selectedReport) { report in
            ReportDetailView(
                report: report,
                viewModel: viewModel,
                item: matchingItem(for: report)
            )
        }
    }

    private func reportList(_ reports: [FoundReport]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(groupedReports(reports), id: \.header) { section in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(section.header)
                            .font(.headline)
                            .foregroundStyle(Color(.label))
                            .padding(.horizontal, TaggoSpacing.horizontalPadding)

                        ForEach(section.items) { report in
                            Button {
                                selectedReport = report
                                Task { await viewModel.markAsRead(report) }
                            } label: {
                                NotificationCardView(
                                    report: report,
                                    itemName: matchingItem(for: report)?.name
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .scrollIndicators(.hidden)
    }

    private func matchingItem(for report: FoundReport) -> Item? {
        if case .loaded(let items) = itemListViewModel.state,
           let found = items.first(where: { $0.id == report.itemID }) {
            return found
        }
        #if DEBUG
        return InboxSeeder.item(for: report)
        #else
        return nil
        #endif
    }

    private func groupedReports(_ reports: [FoundReport]) -> [(header: String, items: [FoundReport])] {
        let calendar = Calendar.current
        let now = Date()
        var today: [FoundReport] = []
        var thisWeek: [FoundReport] = []
        var lastWeek: [FoundReport] = []
        var older: [FoundReport] = []

        for report in reports {
            if calendar.isDateInToday(report.reportedAt) {
                today.append(report)
            } else if calendar.isDate(report.reportedAt, equalTo: now, toGranularity: .weekOfYear) {
                thisWeek.append(report)
            } else if let oneWeekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now),
                      calendar.isDate(report.reportedAt, equalTo: oneWeekAgo, toGranularity: .weekOfYear) {
                lastWeek.append(report)
            } else {
                older.append(report)
            }
        }

        var groups: [(header: String, items: [FoundReport])] = []
        if !today.isEmpty    { groups.append((header: "Today",     items: today)) }
        if !thisWeek.isEmpty { groups.append((header: "This Week", items: thisWeek)) }
        if !lastWeek.isEmpty { groups.append((header: "Last Week", items: lastWeek)) }
        if !older.isEmpty    { groups.append((header: "Older",     items: older)) }
        return groups
    }
}

// MARK: - Empty State

private struct InboxEmptyView: View {
    let message: String
    let isError: Bool

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            if isError {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.red.opacity(0.35))
            } else {
                Image("ibuibu")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }

            Text(message)
                .font(.callout)
                .foregroundStyle(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Notification Card

private struct NotificationCardView: View {
    let report: FoundReport
    let itemName: String?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    statusBadge
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(.tertiaryLabel))
                }

                Text("Someone found your item!")
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(Color(.label))

                Group {
                    if let name = itemName {
                        Text("\(name) was reported found at \(report.station)")
                    } else {
                        Text("Reported found at \(report.station)")
                    }
                }
                .font(.footnote)
                .foregroundStyle(Color(.secondaryLabel))
                .lineSpacing(2)

                Text(report.reportedAt, format: .relative(presentation: .named))
                    .font(.caption)
                    .foregroundStyle(Color(.tertiaryLabel))
                    .padding(.top, 2)
            }
            .padding(14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 4, y: 2)

            if !report.isRead {
                Circle()
                    .fill(Color(red: 1, green: 0.4, blue: 0.35))
                    .frame(width: 12, height: 12)
                    .offset(x: 4, y: -4)
            }
        }
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
    }

    private var statusBadge: some View {
        let isPending = report.status == .pending
        return Text(isPending ? "Pending" : "Claimed")
            .font(.caption2).fontWeight(.semibold)
            .foregroundStyle(Color(.label))
            .padding(.horizontal, 12).padding(.vertical, 4)
            .background((isPending ? Color.yellow : Color.green).opacity(0.35))
            .clipShape(Capsule())
    }
}

#Preview("Full View") {
    let deps = AppDependencies.live
    InboxView(viewModel: deps.makeInboxViewModel(), dependencies: deps)
}

#Preview("Notification Cards") {
    let reports: [(String, String, ReportStatus)] = [
        ("Stasiun Gambir", "Hi, I found it on overhead rack", .pending),
        ("Stasiun Sudirman", "Handed it to the officer", .pending),
        ("Stasiun MRT Lebak Bulus", "Left at lost & found counter", .claimed),
    ]
    ScrollView {
        VStack(spacing: 12) {
            ForEach(Array(reports.enumerated()), id: \.offset) { i, data in
                NotificationCardView(
                    report: FoundReport(
                        id: UUID(), itemID: UUID(),
                        station: data.0, note: data.1, photoData: nil,
                        status: data.2, isRead: i > 0,
                        reportedAt: Calendar.current.date(byAdding: .hour, value: -i * 5, to: Date())!,
                        claimedAt: data.2 == .claimed ? Date() : nil
                    ),
                    itemName: ["Blue Backpack", "AirPods Pro", "Dompet Kulit"][i]
                )
            }
        }
        .padding(.vertical, 16)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Empty Inbox") {
    InboxEmptyView(message: "You got no notification yet", isError: false)
}

#Preview("Error State") {
    InboxEmptyView(message: "Failed to load. Check your connection.", isError: true)
}

// MARK: - Debug Seeder

#if DEBUG
private enum InboxSeeder {
    private static let id1 = UUID()
    private static let id2 = UUID()
    private static let id3 = UUID()
    private static let id4 = UUID()

    static let reports: [FoundReport] = [
        FoundReport(
            id: UUID(), itemID: id1,
            station: "Stasiun Gambir",
            note: "Saya menemukan tas ini di rak bagasi atas, sudah saya serahkan ke petugas.",
            photoData: nil, status: .pending, isRead: false,
            reportedAt: Date().addingTimeInterval(-300),
            claimedAt: nil
        ),
        FoundReport(
            id: UUID(), itemID: id2,
            station: "Stasiun Sudirman",
            note: nil,
            photoData: nil, status: .pending, isRead: false,
            reportedAt: Date().addingTimeInterval(-3600),
            claimedAt: nil
        ),
        FoundReport(
            id: UUID(), itemID: id3,
            station: "Stasiun Tanah Abang",
            note: "Ditemukan di bangku tunggu peron 2, kondisi masih baik.",
            photoData: nil, status: .pending, isRead: true,
            reportedAt: Date().addingTimeInterval(-86400),
            claimedAt: nil
        ),
        FoundReport(
            id: UUID(), itemID: id4,
            station: "Stasiun MRT Lebak Bulus",
            note: nil,
            photoData: nil, status: .claimed, isRead: true,
            reportedAt: Date().addingTimeInterval(-86400 * 8),
            claimedAt: Date().addingTimeInterval(-86400 * 7)
        ),
    ]

    static let items: [Item] = [
        Item(id: id1, ownerID: UUID(), name: "Tas Ransel Biru", category: "Bag",
             color: "Biru Navy", description: "Tas ransel biru navy dengan kompartemen laptop",
             imageData: nil, createdAt: Date(), updatedAt: Date()),
        Item(id: id2, ownerID: UUID(), name: "AirPods Pro", category: "Electronics",
             color: "Putih", description: nil,
             imageData: nil, createdAt: Date(), updatedAt: Date()),
        Item(id: id3, ownerID: UUID(), name: "Dompet Kulit Coklat", category: "Wallet",
             color: "Coklat", description: nil,
             imageData: nil, createdAt: Date(), updatedAt: Date()),
        Item(id: id4, ownerID: UUID(), name: "KTP / ID Card", category: "Document",
             color: "Biru", description: nil,
             imageData: nil, createdAt: Date(), updatedAt: Date()),
    ]

    static func item(for report: FoundReport) -> Item? {
        items.first { $0.id == report.itemID }
    }
}
#endif
