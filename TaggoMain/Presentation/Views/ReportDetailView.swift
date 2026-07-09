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
            Group {
                if showSuccess {
                    ItemFoundSuccessView(onDismiss: { dismiss() })
                } else {
                    ZStack(alignment: .bottom) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                goodNewsHeader

                                itemPhoto
                                    .padding(.top, 16)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item?.name ?? "Your item")
                                        .font(.title2).fontWeight(.bold)
                                        .foregroundStyle(Color(.label))

                                    if let desc = item?.description, !desc.isEmpty {
                                        Text(desc)
                                            .font(.subheadline)
                                            .foregroundStyle(Color(.secondaryLabel))
                                    }
                                }
                                .padding(.horizontal, TaggoSpacing.horizontalPadding)
                                .padding(.top, 16)

                                detailsCard
                                    .padding(.top, 16)

                                importantCard
                                    .padding(.top, 12)

                                needHelpRow
                                    .padding(.top, 16)

                                Spacer(minLength: 120)
                            }
                        }
                        .scrollIndicators(.hidden)
                        .background(Color.taggoBackground)

                        bottomBar
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !showSuccess {
                    ToolbarItem(placement: .cancellationAction) {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left").fontWeight(.medium)
                        }
                    }
                }
            }
        }
        .task(id: showSuccess) {
            guard showSuccess else { return }
            try? await Task.sleep(for: .seconds(1.5))
            dismiss()
        }
    }

    // MARK: - Good News header

    private var goodNewsHeader: some View {
        VStack(spacing: 6) {
            Text("Good News!")
                .font(.largeTitle).fontWeight(.bold)
                .foregroundStyle(Color(.label))
            Text("Someone found your item")
                .font(.subheadline)
                .foregroundStyle(Color.taggoBlue)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    // MARK: - Item Photo

    private var itemPhoto: some View {
        GeometryReader { proxy in
            Group {
                let photoData = item?.imageData ?? report.photoData
                if let data = photoData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.taggoBlueLight
                        .overlay {
                            Image(systemName: "photo")
                                .font(.system(size: 48))
                                .foregroundStyle(Color.taggoBlue.opacity(0.4))
                        }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius)
                .stroke(Color.taggoBlue.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
    }

    // MARK: - Details card

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Details")
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

            Divider()
                .padding(.horizontal, 16)

            DetailRow(icon: "mappin.circle.fill", iconColor: .taggoBlue,
                      label: "Found at", value: report.station)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

            Divider()
                .padding(.horizontal, 16)

            DetailRow(icon: "calendar", iconColor: .taggoBlue,
                      label: "Date",
                      value: report.reportedAt.formatted(date: .long, time: .omitted))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

            if let note = report.note, !note.isEmpty {
                Divider()
                    .padding(.horizontal, 16)

                DetailRow(icon: "pencil.circle.fill", iconColor: .taggoBlue,
                          label: "Note from finder",
                          value: "\"\(note)\"")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius))
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
    }

    // MARK: - Important card

    private var importantCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.orange)
                .font(.title3)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 4) {
                Text("Important")
                    .font(.subheadline).fontWeight(.semibold)
                Text("Please contact the station officer for verification and instructions on how to claim your item.")
                    .font(.caption)
                    .foregroundStyle(Color(.secondaryLabel))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(Color.orange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
    }

    // MARK: - Need help row

    private var needHelpRow: some View {
        HStack {
            Text("Need help?")
                .font(.subheadline)
                .foregroundStyle(Color(.secondaryLabel))
            Spacer()
            Button {
                // Contact support
            } label: {
                Label("Contact Support", systemImage: "headphones")
                    .font(.caption).fontWeight(.semibold)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
            }
            .foregroundStyle(.primary)
        }
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        VStack(spacing: 8) {
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
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("You've already collected this item.")
                        .font(.subheadline)
                        .foregroundStyle(Color(.secondaryLabel))
                }
                .padding(.vertical, 16)
            }

            Text("Never share personal information with unknown parties.")
                .font(.caption2)
                .foregroundStyle(Color(.tertiaryLabel))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }

    private func markClaimed() async {
        isMarkingClaimed = true
        await viewModel.markClaimed(report)
        if let updated = viewModel.reports.first(where: { $0.id == report.id }) {
            report = updated
            if updated.status == .claimed {
                showSuccess = true
            }
        }
        isMarkingClaimed = false
    }
}

// MARK: - Detail Row

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
                    .font(.caption)
                    .foregroundStyle(Color(.secondaryLabel))
                Text(value)
                    .font(.subheadline).fontWeight(.semibold)
                    .fixedSize(horizontal: false, vertical: true)
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
                    color: "Navy Blue", description: "Tas punggung warna biru navy dengan kompartemen laptop",
                    imageData: nil, createdAt: Date(), updatedAt: Date())
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
