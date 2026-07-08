//
//  ReportDetailView.swift
//  TaggoMain
//

import SwiftUI

struct ReportDetailView: View {
    let viewModel: InboxViewModel
    let item: Item?
    @State private var report: FoundReport
    @State private var isMarkingClaimed = false
    @State private var showSuccess = false
    @Environment(\.dismiss) private var dismiss

    init(report: FoundReport, viewModel: InboxViewModel, item: Item? = nil) {
        _report = State(initialValue: report)
        self.viewModel = viewModel
        self.item = item
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        goodNewsHeader
                        photoGallery
                            .padding(.top, 16)

                        Text(item?.name ?? "Your item")
                            .font(.title2).fontWeight(.bold)
                            .padding(.horizontal, TaggoSpacing.horizontalPadding)
                            .padding(.top, 16)

                        detailsSection
                            .padding(.top, 16)

                        openMapButton
                            .padding(.top, 12)

                        importantCard
                            .padding(.top, 12)

                        needHelpRow
                            .padding(.top, 12)

                        Spacer(minLength: 120)
                    }
                }
                .scrollIndicators(.hidden)
                .background(Color(.systemBackground))

                bottomBar
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left").fontWeight(.medium)
                    }
                }
            }
            .fullScreenCover(isPresented: $showSuccess) {
                ItemFoundSuccessView {
                    showSuccess = false
                    dismiss()
                }
            }
        }
    }

    // MARK: "Good News!" header
    private var goodNewsHeader: some View {
        VStack(spacing: 6) {
            Text("Good News!")
                .font(.largeTitle).fontWeight(.bold)
            Text("Someone found your item")
                .font(.subheadline).foregroundStyle(Color.taggoBlue)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: Photo gallery — large left, 2 thumbnails right
    private var photoGallery: some View {
        HStack(spacing: 8) {
            photoView(item?.imageData ?? report.photoData)
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(spacing: 8) {
                photoView(item?.imageData)
                    .frame(width: 90, height: 106)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                photoView(report.photoData)
                    .frame(width: 90, height: 106)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
    }

    @ViewBuilder
    private func photoView(_ data: Data?) -> some View {
        if let data, let img = UIImage(data: data) {
            Image(uiImage: img).resizable().scaledToFill()
        } else {
            Color.taggoBlueLight.overlay {
                Image(systemName: "photo")
                    .foregroundStyle(Color.taggoBlue.opacity(0.4))
                    .font(.title2)
            }
        }
    }

    // MARK: Details rows
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details").font(.headline)

            DetailRow(icon: "mappin.circle.fill", iconColor: .taggoBlue,
                      label: "Found at", value: report.station)

            DetailRow(icon: "calendar", iconColor: .taggoBlue,
                      label: "Date and Time",
                      value: report.reportedAt.formatted(date: .long, time: .omitted))

            if let note = report.note, !note.isEmpty {
                DetailRow(icon: "pencil.circle.fill", iconColor: .taggoBlue,
                          label: "Notes from finder",
                          value: "\"\(note)\"")
            }
        }
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
    }

    // MARK: Open Maps button
    private var openMapButton: some View {
        Button {
            let query = report.station
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let url = URL(string: "maps://?q=\(query)") {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack {
                Image(systemName: "mappin.circle").font(.title3)
                Text("Open location on map").font(.subheadline).fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.right").font(.caption)
            }
            .padding(14)
            .background(Color.taggoBlue.opacity(0.08))
            .foregroundStyle(Color.taggoBlue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
    }

    // MARK: Important card
    private var importantCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.orange).font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text("Important").font(.subheadline).fontWeight(.semibold)
                Text("Please contact the station officer for verification and instructions on how to claim your item.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color.orange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
    }

    // MARK: Need help row
    private var needHelpRow: some View {
        HStack {
            Text("Need help?").font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Button {
                // Contact support action
            } label: {
                Label("Contact Support", systemImage: "headphones")
                    .font(.caption).fontWeight(.semibold)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
            }
            .foregroundStyle(.primary)
        }
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
    }

    // MARK: Bottom bar — claim button + disclaimer
    private var bottomBar: some View {
        VStack(spacing: 6) {
            Divider()
            if report.status == .pending {
                Button {
                    Task { await markClaimed() }
                } label: {
                    Group {
                        if isMarkingClaimed {
                            ProgressView().tint(.white)
                        } else {
                            Text("I've Collected My Item")
                                .font(.headline)
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.taggoBlue)
                    .clipShape(Capsule())
                }
                .disabled(isMarkingClaimed)
                .padding(.horizontal, TaggoSpacing.horizontalPadding)
            } else {
                Text("You've already collected this item.")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .padding(.vertical, 16)
            }

            Text("Never share personal information with unknown parties.")
                .font(.caption2).foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }

    private func markClaimed() async {
        isMarkingClaimed = true
        await viewModel.markClaimed(report)
        if case .loaded(let reports) = viewModel.state,
           let updated = reports.first(where: { $0.id == report.id }) {
            report = updated
            if updated.status == .claimed {
                showSuccess = true
            }
        }
        isMarkingClaimed = false
    }
}

// MARK: - Detail Row component

private struct DetailRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .font(.title3)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.caption).foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline).fontWeight(.semibold)
            }
        }
    }
}

#Preview("Pending — with note") {
    let report = FoundReport(id: UUID(), itemID: UUID(), station: "Stasiun Gambir",
                             note: "Hi, I found this item on the overhead rack and handed it to the station officer.",
                             photoData: nil, status: .pending, isRead: false,
                             reportedAt: Date(), claimedAt: nil)
    let item = Item(id: UUID(), ownerID: UUID(), name: "Blue Backpack", category: "Bag",
                    color: "Navy Blue", description: nil, imageData: nil,
                    createdAt: Date(), updatedAt: Date())
    ReportDetailView(report: report, viewModel: AppDependencies.live.makeInboxViewModel(), item: item)
}

#Preview("Claimed") {
    let report = FoundReport(id: UUID(), itemID: UUID(), station: "Stasiun Sudirman",
                             note: nil, photoData: nil,
                             status: .claimed, isRead: true,
                             reportedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                             claimedAt: Date())
    ReportDetailView(report: report, viewModel: AppDependencies.live.makeInboxViewModel())
}
