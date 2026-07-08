//
//  InboxView.swift
//  TaggoMain
//

import SwiftUI

struct InboxView: View {
    @State private var viewModel: InboxViewModel
    @State private var itemListViewModel: ItemListViewModel
    @State private var selectedReport: FoundReport?
    @Environment(\.dismiss) private var dismiss

    init(viewModel: InboxViewModel, dependencies: AppDependencies) {
        _viewModel = State(initialValue: viewModel)
        _itemListViewModel = State(initialValue: dependencies.makeItemListViewModel())
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .failure(let message):
                    InboxEmptyView(message: message, isError: true)

                case .loaded(let reports) where reports.isEmpty:
                    InboxEmptyView(message: "You got no notification yet", isError: false)

                case .loaded(let reports):
                    reportList(reports)
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
    }

    private func reportList(_ reports: [FoundReport]) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(groupedReports(reports), id: \.header) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.header)
                            .font(.subheadline).fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, TaggoSpacing.horizontalPadding)

                        ForEach(section.items) { report in
                            Button {
                                selectedReport = report
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
        guard case .loaded(let items) = itemListViewModel.state else { return nil }
        return items.first { $0.id == report.itemID }
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
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: isError ? "exclamationmark.triangle" : "bell.slash")
                .font(.system(size: 72))
                .foregroundStyle(isError ? Color.red.opacity(0.4) : Color.taggoBlue.opacity(0.3))

            Text(message)
                .font(.subheadline).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Notification Card

private struct NotificationCardView: View {
    let report: FoundReport
    let itemName: String?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            thumbnail

            VStack(alignment: .leading, spacing: 5) {
                statusBadge

                Text("Someone found your item!")
                    .font(.subheadline).fontWeight(.bold)
                    .foregroundStyle(.primary)

                if let name = itemName {
                    Text("\(name) was reported found at \(report.station)")
                        .font(.caption).foregroundStyle(.secondary)
                        .lineLimit(1)
                } else {
                    Text("Reported found at \(report.station)")
                        .font(.caption).foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Text(report.reportedAt, format: .relative(presentation: .named))
                    .font(.caption2).foregroundStyle(.tertiary)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(.tertiary)
                .padding(.top, 4)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let data = report.photoData, let img = UIImage(data: data) {
            Image(uiImage: img)
                .resizable().scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.taggoBlueLight)
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: "bag")
                        .foregroundStyle(Color.taggoBlue.opacity(0.5))
                }
        }
    }

    private var statusBadge: some View {
        Text(report.status == .pending ? "Pending" : "Claimed")
            .font(.caption2).fontWeight(.semibold)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(report.status == .pending
                ? Color.yellow.opacity(0.25)
                : Color.green.opacity(0.15))
            .foregroundStyle(report.status == .pending ? Color.orange : Color.green)
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
