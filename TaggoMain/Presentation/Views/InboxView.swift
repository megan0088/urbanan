//
//  InboxView.swift
//  TaggoMain
//

import SwiftUI

struct InboxView: View {
    @State private var viewModel: InboxViewModel
    @State private var selectedReport: FoundReport?

    init(viewModel: InboxViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .failure(let message):
                ContentUnavailableView(message, systemImage: "exclamationmark.triangle")
            case .loaded(let reports) where reports.isEmpty:
                ContentUnavailableView("No reports yet", systemImage: "tray")
            case .loaded(let reports):
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(reports) { report in
                            Button {
                                selectedReport = report
                            } label: {
                                FoundReportCardView(report: report)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
        .task {
            await viewModel.load()
        }
        .task {
            await viewModel.observeFoundReportEvents()
        }
        .refreshable {
            await viewModel.load()
        }
        .sheet(item: $selectedReport) { report in
            ReportDetailView(report: report, viewModel: viewModel)
        }
    }
}

private struct FoundReportCardView: View {
    let report: FoundReport

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            thumbnail
            VStack(alignment: .leading, spacing: 4) {
                Text(report.station)
                    .font(.headline)
                if let note = report.note, !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Text(report.reportedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            statusBadge
        }
        .padding(12)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 1)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let photoData = report.photoData, let uiImage = UIImage(data: photoData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(.gray.opacity(0.2))
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: "shippingbox")
                        .foregroundStyle(.secondary)
                }
        }
    }

    private var statusBadge: some View {
        Text(report.status == .claimed ? "Claimed" : "New")
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(report.status == .claimed ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
            .foregroundStyle(report.status == .claimed ? Color.green : Color.orange)
            .clipShape(Capsule())
    }
}
