//
//  InboxView.swift
//  TaggoMain
//

import SwiftUI

struct InboxView: View {
    @State private var viewModel: InboxViewModel

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
                List(reports) { report in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(report.station)
                                .font(.headline)
                            Spacer()
                            if report.status == .claimed {
                                Text("Claimed")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        if let note = report.note, !note.isEmpty {
                            Text(note)
                                .font(.subheadline)
                        }
                        Text(report.reportedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if report.status == .pending {
                            Button("Mark Claimed") {
                                Task { await viewModel.markClaimed(report) }
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }
        .task {
            await viewModel.observeFoundReportEvents()
        }
    }
}
