//
//  ReportView.swift
//  TaggoClip
//

import SwiftUI
import PhotosUI

struct ReportView: View {
    @State private var viewModel: ReportViewModel
    @State private var showForm = false
    @State private var photosPickerItems: [PhotosPickerItem] = []
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
            loadingView(message: "Loading item…")
        case .found(let item):
            if showForm {
                formView(for: item)
            } else {
                welcomeView
            }
        case .submitting:
            loadingView(message: "Sending notification…")
        case .success:
            successView
        case .failure(let message):
            errorView(message: message)
        }
    }

    // MARK: - Loading

    private func loadingView(message: String) -> some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Welcome

    private var welcomeView: some View {
        VStack(spacing: 0) {
            Spacer()

            Image("petugasl&f")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .padding(.bottom, 24)

            Text("You Found\nSomeone's Item")
                .font(.title).fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Help return this item.\nShare where you found it and we'll\ntake care of the rest")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.horizontal, 32)

            Spacer()

            Button {
                withAnimation { showForm = true }
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(taggoBlue)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Form

    private func formView(for item: Item) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("A few details, please.")
                            .font(.title2).fontWeight(.bold)
                        Text("Help the owner recognize where and how you found this item")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                    // Location field
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 12) {
                            Image(systemName: "location.fill")
                                .foregroundStyle(taggoBlue)
                                .frame(width: 20)
                            Text("Location")
                                .font(.subheadline).fontWeight(.medium)
                        }
                        .padding(.horizontal, 20)

                        HStack {
                            TextField("Where did you find it?", text: $viewModel.station)
                                .font(.subheadline)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(14)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 20)
                    }

                    // Notes field
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 12) {
                            Image(systemName: "pencil")
                                .foregroundStyle(taggoBlue)
                                .frame(width: 20)
                            Text("Notes")
                                .font(.subheadline).fontWeight(.medium)
                        }
                        .padding(.horizontal, 20)

                        TextField("Leave some notes for owner...", text: $viewModel.note, axis: .vertical)
                            .font(.subheadline)
                            .lineLimit(4, reservesSpace: true)
                            .padding(14)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 20)
                    }

                    // Photo section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your Photo")
                            .font(.subheadline).fontWeight(.medium)
                            .padding(.horizontal, 20)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(0..<photosPickerItems.count, id: \.self) { index in
                                    PhotoThumbnailView(item: photosPickerItems[index])
                                }

                                addPhotoButton
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .onChange(of: photosPickerItems) { _, newItems in
                        Task {
                            if let first = newItems.first,
                               let data = try? await first.loadTransferable(type: Data.self) {
                                viewModel.selectedPhotoData = data
                            }
                        }
                    }

                    Spacer(minLength: 120)
                }
            }
            .background(Color(.systemGroupedBackground))
            .scrollIndicators(.hidden)

            // Bottom CTA
            VStack(spacing: 6) {
                Button {
                    Task { await viewModel.submitReport() }
                } label: {
                    Text("Send Notification to Owner")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(viewModel.station.isEmpty ? Color.secondary : taggoBlue)
                        .clipShape(Capsule())
                }
                .disabled(viewModel.station.isEmpty)
                .padding(.horizontal, 24)

                Text("Your report is secure and confidential")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 12)
            .padding(.bottom, 32)
            .background(Color(.systemGroupedBackground))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Add Photo Button

    private var addPhotoButton: some View {
        let isEmpty = photosPickerItems.isEmpty
        let width: CGFloat = isEmpty ? 260 : 72
        return PhotosPicker(selection: $photosPickerItems, maxSelectionCount: 5, matching: .images) {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(taggoBlue.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                .frame(width: width, height: 72)
                .overlay {
                    if isEmpty {
                        VStack(spacing: 6) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 28))
                                .foregroundStyle(taggoBlue)
                            Text("Add photo")
                                .font(.caption)
                                .foregroundStyle(taggoBlue)
                        }
                    } else {
                        Image(systemName: "plus")
                            .foregroundStyle(taggoBlue)
                    }
                }
        }
    }

    // MARK: - Success

    private var successView: some View {
        VStack(spacing: 0) {
            Spacer()

            Image("petugasl&f")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .padding(.bottom, 24)

            Text("Report Submitted")
                .font(.title).fontWeight(.bold)

            Text("Thanks for helping.\nThe owner has been notified.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.horizontal, 32)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Error

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private let taggoBlue = Color("TaggoBlue")
}

// MARK: - Photo Thumbnail

private struct PhotoThumbnailView: View {
    let item: PhotosPickerItem
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.secondary.opacity(0.2)
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                image = UIImage(data: data)
            }
        }
    }
}
