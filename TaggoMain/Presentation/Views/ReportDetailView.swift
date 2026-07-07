//
//  ReportDetailView.swift
//  TaggoMain
//

import SwiftUI

struct ReportDetailView: View {
    let viewModel: InboxViewModel
    @State private var report: FoundReport
    @State private var isMarkingClaimed = false
    @Environment(\.dismiss) private var dismiss

    init(report: FoundReport, viewModel: InboxViewModel) {
        _report = State(initialValue: report)
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Report Details") {
                    LabeledContent("Station", value: report.station)
                    LabeledContent("Reported", value: report.reportedAt.formatted(date: .abbreviated, time: .shortened))
                }

                Section("Note") {
                    if let note = report.note, !note.isEmpty {
                        Text(note)
                    } else {
                        Text("The finder didn't leave a note.")
                            .foregroundStyle(.secondary)
                            .italic()
                    }
                }

                Section("Photo") {
                    if let photoData = report.photoData, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 220)
                    } else {
                        Text("The finder didn't attach a photo.")
                            .foregroundStyle(.secondary)
                            .italic()
                    }
                }

                Section("Status") {
                    LabeledContent("Status", value: report.status == .claimed ? "Claimed" : "Pending")
                    if let claimedAt = report.claimedAt {
                        LabeledContent("Claimed on", value: claimedAt.formatted(date: .abbreviated, time: .shortened))
                    }
                }

                if report.status == .pending {
                    Section {
                        Button {
                            Task { await markClaimed() }
                        } label: {
                            if isMarkingClaimed {
                                ProgressView()
                            } else {
                                Text("Mark as Claimed")
                            }
                        }
                        .disabled(isMarkingClaimed)
                    }
                }

                if case .failure(let message) = viewModel.state {
                    Text(message).foregroundStyle(.red)
                }
            }
            .navigationTitle("Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func markClaimed() async {
        isMarkingClaimed = true
        await viewModel.markClaimed(report)
        if case .loaded(let reports) = viewModel.state,
           let updated = reports.first(where: { $0.id == report.id }) {
            report = updated
        }
        isMarkingClaimed = false
    }
}
