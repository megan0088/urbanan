//
//  ReportView.swift
//  TaggoClip
//

import SwiftUI
import PhotosUI

private enum ClipSpacing {
    static var horizontal: CGFloat { 24 }
    static var cardCorner: CGFloat { 16 }
}

struct ReportView: View {
    @State private var viewModel: ReportViewModel
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var showForm = false
    let invocationURL: URL?

    init(viewModel: ReportViewModel, invocationURL: URL?) {
        _viewModel = State(initialValue: viewModel)
        self.invocationURL = invocationURL
    }

    var body: some View {
        content
            .task(id: invocationURL) {
                if let invocationURL {
                    await viewModel.handleInvocation(url: invocationURL)
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .resolving:
            ClipLoadingView()
        case .found(let item):
            if showForm {
                formView
            } else {
                ClipWelcomeView(item: item, onContinue: { showForm = true })
            }
        case .submitting:
            ClipSubmittingView()
        case .success:
            ClipSuccessView()
        case .failure(let message):
            ClipFailureView(message: message)
        }
    }

    // MARK: - Form (keeps ViewModel bindings inline)

    private var formView: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("A few details, please.")
                        .font(.title2).fontWeight(.bold)
                        .padding(.horizontal, ClipSpacing.horizontal)
                        .padding(.top, 24)

                    Text("Help the owner recognize where and how you found this item")
                        .font(.subheadline).foregroundStyle(.secondary)
                        .padding(.horizontal, ClipSpacing.horizontal)
                        .padding(.top, 4)
                        .padding(.bottom, 24)

                    locationField
                        .padding(.bottom, 16)

                    notesField
                        .padding(.bottom, 16)

                    photoSection

                    Spacer(minLength: 100)
                }
            }
            .scrollIndicators(.hidden)
            .background(Color.taggoBackground)

            sendBar
        }
    }

    private var locationField: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: "mappin.circle")
                    .font(.title3).foregroundStyle(Color.taggoBlue).frame(width: 28)
                Text("Location*").font(.subheadline).fontWeight(.semibold)
            }
            .padding(.horizontal, ClipSpacing.horizontal)

            HStack {
                TextField("Where did you find it?", text: $viewModel.station)
                    .font(.subheadline)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption).fontWeight(.semibold).foregroundStyle(.tertiary)
            }
            .padding(.horizontal, ClipSpacing.horizontal)
            .padding(.vertical, 14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: ClipSpacing.cardCorner))
            .padding(.horizontal, ClipSpacing.horizontal)
        }
    }

    private var notesField: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: "pencil.circle")
                    .font(.title3).foregroundStyle(Color.taggoBlue).frame(width: 28)
                Text("Notes (optional)").font(.subheadline).fontWeight(.semibold)
            }
            .padding(.horizontal, ClipSpacing.horizontal)

            TextField("Leave some notes for owner...", text: $viewModel.note, axis: .vertical)
                .font(.subheadline)
                .lineLimit(3...5)
                .padding(.horizontal, ClipSpacing.horizontal)
                .padding(.vertical, 14)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: ClipSpacing.cardCorner))
                .padding(.horizontal, ClipSpacing.horizontal)
        }
    }

    private var photoSection: some View {
        let photoData = viewModel.selectedPhotoData
        let blue = Color.taggoBlue
        return VStack(alignment: .leading, spacing: 8) {
            Text("Your Photo (optional)")
                .font(.subheadline).fontWeight(.semibold)
                .padding(.horizontal, ClipSpacing.horizontal)

            PhotosPicker(selection: $photosPickerItem, matching: .images) {
                GeometryReader { proxy in
                    Group {
                        if let data = photoData, let img = UIImage(data: data) {
                            Image(uiImage: img).resizable().scaledToFill()
                        } else {
                            Color(.systemBackground)
                                .overlay {
                                    VStack(spacing: 8) {
                                        Image(systemName: "camera.fill")
                                            .font(.title2)
                                            .foregroundStyle(blue.opacity(0.5))
                                        Text("Add photo")
                                            .font(.subheadline).fontWeight(.medium)
                                            .foregroundStyle(blue)
                                        Text("Please take a photo of the item")
                                            .font(.caption).foregroundStyle(blue.opacity(0.7))
                                    }
                                }
                        }
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: ClipSpacing.cardCorner))
                .overlay(
                    RoundedRectangle(cornerRadius: ClipSpacing.cardCorner)
                        .strokeBorder(blue.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                )
            }
            .padding(.horizontal, ClipSpacing.horizontal)
            .onChange(of: photosPickerItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        viewModel.selectedPhotoData = data
                    }
                }
            }
        }
    }

    private var sendBar: some View {
        VStack(spacing: 0) {
            Divider()
            Button {
                Task { await viewModel.submitReport() }
            } label: {
                Text("Send Notification to Owner")
                    .font(.headline).foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(viewModel.isStationValid ? Color.taggoBlue : Color.secondary)
                    .clipShape(Capsule())
            }
            .disabled(!viewModel.isStationValid)
            .padding(.horizontal, ClipSpacing.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 4)

            Text("Your report is secure and confidential.")
                .font(.caption2).foregroundStyle(.tertiary)
                .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Screen: Loading

private struct ClipLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView().scaleEffect(1.3)
            Text("Looking up item…")
                .font(.subheadline).foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Screen: Welcome

private struct ClipWelcomeView: View {
    let item: Item
    var onContinue: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                Spacer()

                Image("petugasl&f")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 220)
                    .padding(.bottom, 28)

                Text("You Found\nSomeone's Item")
                    .font(.largeTitle).fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Help return this item. Share where you found it and we'll take care of the rest")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, ClipSpacing.horizontal)
                    .padding(.top, 12)

                // Identity confirmation — reassures the finder this actually
                // resolved to a real item, without listing category/color,
                // which mean nothing to someone holding the physical object.
                HStack(spacing: 10) {
                    Group {
                        if let data = item.imageData, let img = UIImage(data: data) {
                            Image(uiImage: img).resizable().scaledToFill()
                        } else {
                            Color.taggoBlueLight
                                .overlay {
                                    Image(systemName: "shippingbox.fill")
                                        .foregroundStyle(Color.taggoBlue)
                                }
                        }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    Text(item.name)
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundStyle(Color(.label))
                }
                .padding(10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.top, 20)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))

            VStack(spacing: 0) {
                Divider()
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline).foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.taggoBlue)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, ClipSpacing.horizontal)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
            }
        }
    }
}

// MARK: - Screen: Submitting

private struct ClipSubmittingView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView().scaleEffect(1.3)
            Text("Submitting…")
                .font(.subheadline).foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Screen: Success

private struct ClipSuccessView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image("report_submitted")
                .resizable()
                .scaledToFit()
                .frame(height: 240)
                .padding(.bottom, 28)

            Text("Report Submitted!")
                .font(.largeTitle).fontWeight(.bold)

            Text("Thanks for helping. The owner has been notified.")
                .font(.subheadline).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, ClipSpacing.horizontal)
                .padding(.top, 10)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Screen: Failure

private struct ClipFailureView: View {
    let message: String

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 64))
                .foregroundStyle(Color.taggoBlue.opacity(0.4))
            Text(message)
                .font(.subheadline).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Previews

#Preview("Welcome") {
    ClipWelcomeView(
        item: Item(id: UUID(), ownerID: UUID(), name: "Blue Backpack", category: "Bag",
                   color: "Navy Blue", description: nil, imageData: nil,
                   createdAt: Date(), updatedAt: Date()),
        onContinue: {}
    )
}

#Preview("Form") {
    struct FormPreview: View {
        @State private var station = ""
        @State private var note = ""
        @State private var photosPickerItem: PhotosPickerItem?
        var body: some View {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("A few details, please.")
                            .font(.title2).fontWeight(.bold)
                            .padding(.horizontal, ClipSpacing.horizontal)
                            .padding(.top, 24)
                        Text("Help the owner recognize where and how you found this item")
                            .font(.subheadline).foregroundStyle(.secondary)
                            .padding(.horizontal, ClipSpacing.horizontal)
                            .padding(.top, 4)
                            .padding(.bottom, 24)

                        // Location
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 10) {
                                Image(systemName: "mappin.circle")
                                    .font(.title3).foregroundStyle(Color.taggoBlue).frame(width: 28)
                                Text("Location*").font(.subheadline).fontWeight(.semibold)
                            }
                            .padding(.horizontal, ClipSpacing.horizontal)
                            HStack {
                                TextField("Where did you find it?", text: $station).font(.subheadline)
                                Spacer()
                                Image(systemName: "chevron.right").font(.caption).fontWeight(.semibold).foregroundStyle(.tertiary)
                            }
                            .padding(.horizontal, ClipSpacing.horizontal)
                            .padding(.vertical, 14)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: ClipSpacing.cardCorner))
                            .padding(.horizontal, ClipSpacing.horizontal)
                        }
                        .padding(.bottom, 16)

                        // Notes
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 10) {
                                Image(systemName: "pencil.circle")
                                    .font(.title3).foregroundStyle(Color.taggoBlue).frame(width: 28)
                                Text("Notes (optional)").font(.subheadline).fontWeight(.semibold)
                            }
                            .padding(.horizontal, ClipSpacing.horizontal)
                            TextField("Leave some notes for owner...", text: $note, axis: .vertical)
                                .font(.subheadline).lineLimit(3...5)
                                .padding(.horizontal, ClipSpacing.horizontal)
                                .padding(.vertical, 14)
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: ClipSpacing.cardCorner))
                                .padding(.horizontal, ClipSpacing.horizontal)
                        }
                        .padding(.bottom, 16)

                        // Photo placeholder
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Photo (optional)").font(.subheadline).fontWeight(.semibold)
                                .padding(.horizontal, ClipSpacing.horizontal)
                            PhotosPicker(selection: $photosPickerItem, matching: .images) {
                                Color(.systemBackground)
                                    .overlay {
                                        VStack(spacing: 8) {
                                            Image(systemName: "camera.fill").font(.title2).foregroundStyle(Color.taggoBlue.opacity(0.5))
                                            Text("Add photo").font(.subheadline).fontWeight(.medium).foregroundStyle(Color.taggoBlue)
                                            Text("Please take a photo of the item").font(.caption).foregroundStyle(Color.taggoBlue.opacity(0.7))
                                        }
                                    }
                                    .frame(maxWidth: .infinity).frame(height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: ClipSpacing.cardCorner))
                                    .overlay(RoundedRectangle(cornerRadius: ClipSpacing.cardCorner)
                                        .strokeBorder(Color.taggoBlue.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [6])))
                            }
                            .padding(.horizontal, ClipSpacing.horizontal)
                        }

                        Spacer(minLength: 100)
                    }
                }
                .scrollIndicators(.hidden)
                .background(Color.taggoBackground)

                VStack(spacing: 0) {
                    Divider()
                    Text("Send Notification to Owner")
                        .font(.headline).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(station.isEmpty ? Color.secondary : Color.taggoBlue)
                        .clipShape(Capsule())
                        .padding(.horizontal, ClipSpacing.horizontal)
                        .padding(.top, 12).padding(.bottom, 4)
                    Text("Your report is secure and confidential.")
                        .font(.caption2).foregroundStyle(.tertiary).padding(.bottom, 12)
                }
                .background(Color(.systemBackground))
            }
        }
    }
    return FormPreview()
}

#Preview("Submitting") {
    ClipSubmittingView()
}

#Preview("Success") {
    ClipSuccessView()
}

#Preview("Error") {
    ClipFailureView(message: "We couldn't find this item. Make sure you're scanning the correct QR code.")
}
