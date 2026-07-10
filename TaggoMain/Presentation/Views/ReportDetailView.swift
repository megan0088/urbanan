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
    @State private var selectedPhotoID: String?
    @Environment(\.dismiss) private var dismiss

    init(report: FoundReport, viewModel: InboxViewModel, item: Item? = nil) {
        _report = State(initialValue: report)
        self.viewModel = viewModel
        self.item = item
        // Finder's photo is the default focus — it's the evidence for this
        // specific report, whereas the item's own photo is just for reference.
        _selectedPhotoID = State(initialValue: report.photoData != nil ? "finder" : (item?.imageData != nil ? "item" : nil))
    }

    var body: some View {
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

                            VStack(alignment: .leading, spacing: 6) {
                                statusBadge

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
                .foregroundStyle(Color(.secondaryLabel))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    // MARK: - Item Photo Gallery

    /// Up to two photos can exist for a report: the finder's attached photo
    /// (evidence for this specific report) and the item's own registered photo.
    /// Both are shown as distinct, labeled thumbnails rather than silently
    /// swapping one image for another — the owner should always be able to
    /// see plainly that there are two different photos, and which is which.
    private struct PhotoOption: Identifiable {
        let id: String
        let label: String
        let data: Data
    }

    private var photoOptions: [PhotoOption] {
        var options: [PhotoOption] = []
        if let finderData = report.photoData {
            options.append(PhotoOption(id: "finder", label: "Photo from finder", data: finderData))
        }
        if let itemData = item?.imageData {
            options.append(PhotoOption(id: "item", label: "Your item's photo", data: itemData))
        }
        return options
    }

    private var itemPhoto: some View {
        let options = photoOptions
        let selected = options.first(where: { $0.id == selectedPhotoID }) ?? options.first

        return HStack(alignment: .top, spacing: 10) {
            ZStack(alignment: .bottomLeading) {
                ClippedFillImage(data: selected?.data)
                    .clipShape(RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius)
                            .stroke(Color.taggoBlue.opacity(0.2), lineWidth: 1)
                    )

                if let selected {
                    Text(selected.label)
                        .font(.caption2).fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.black.opacity(0.55))
                        .clipShape(Capsule())
                        .padding(10)
                }
            }
            .frame(height: 220)

            if options.count > 1 {
                VStack(spacing: 8) {
                    ForEach(options) { option in
                        Button {
                            selectedPhotoID = option.id
                        } label: {
                            ClippedFillImage(data: option.data)
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            selectedPhotoID == option.id ? Color.taggoBlue : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
    }

    // MARK: - Status badge

    private var statusBadge: some View {
        let isPending = report.status == .pending
        return Text(isPending ? "Missing" : "Safe")
            .font(.caption2).fontWeight(.semibold)
            .foregroundStyle(Color(.label))
            .padding(.horizontal, 12).padding(.vertical, 4)
            .background((isPending ? Color.yellow : Color.green).opacity(0.35))
            .clipShape(Capsule())
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

            Divider()
                .padding(.horizontal, 16)

            DetailRow(icon: "pencil.circle.fill", iconColor: .taggoBlue,
                      label: "Note from finder",
                      value: report.note.flatMap { $0.isEmpty ? nil : "\"\($0)\"" } ?? "No notes provided")
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
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

// MARK: - Clipped Fill Image

/// Resizes+crops image data to whatever frame the caller applies, without
/// letting a wide/tall source image stretch the container (see the frame
/// stretching issue fixed elsewhere in the app's photo views).
private struct ClippedFillImage: View {
    let data: Data?

    var body: some View {
        GeometryReader { proxy in
            Group {
                if let data, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.taggoBlueLight
                        .overlay {
                            Image(systemName: "photo")
                                .font(.system(size: 32))
                                .foregroundStyle(Color.taggoBlue.opacity(0.4))
                        }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
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
    NavigationStack {
        ReportDetailView(report: report, viewModel: AppDependencies.live.makeInboxViewModel(), item: item)
    }
}

#Preview("Claimed") {
    let report = FoundReport(id: UUID(), itemID: UUID(), station: "Stasiun Sudirman",
                             note: nil, photoData: nil,
                             status: .claimed, isRead: true,
                             reportedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                             claimedAt: Date())
    NavigationStack {
        ReportDetailView(report: report, viewModel: AppDependencies.live.makeInboxViewModel())
    }
}
