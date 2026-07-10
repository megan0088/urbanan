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

            case .failure where viewModel.displayReports.isEmpty:
                InboxEmptyView(message: "Failed to load notifications.", isError: true)

            default:
                if viewModel.displayReports.isEmpty {
                    InboxEmptyView(message: "You got no notification yet", isError: false)
                } else {
                    reportList
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
        .navigationDestination(item: $selectedReport) { report in
            ReportDetailView(
                report: report,
                viewModel: viewModel,
                item: viewModel.item(for: report, in: itemListViewModel.items)
            )
        }
    }

    private var reportList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(viewModel.groupedSections) { section in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(section.header)
                            .font(.headline)
                            .foregroundStyle(Color(.label))
                            .padding(.horizontal, TaggoSpacing.horizontalPadding)

                        ForEach(section.reports) { report in
                            Button {
                                selectedReport = report
                                Task { await viewModel.markAsRead(report) }
                            } label: {
                                NotificationCardView(
                                    report: report,
                                    itemName: viewModel.item(for: report, in: itemListViewModel.items)?.name
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
        return Text(isPending ? "Missing" : "Safe")
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
