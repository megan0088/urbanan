//
//  ReportFormView.swift
//  TaggoMain
//

import SwiftUI
import PhotosUI

struct ReportFormView: View {
    @State private var viewModel: ReportFormViewModel
    @State private var photosPickerItem: PhotosPickerItem?
    var onFinished: (() -> Void)?

    init(viewModel: ReportFormViewModel, onFinished: (() -> Void)? = nil) {
        _viewModel = State(initialValue: viewModel)
        self.onFinished = onFinished
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.state == .success {
                    reportSuccess
                } else {
                    reportForm
                }
            }
            .navigationTitle("Report Found Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onFinished?() }
                }
            }
        }
    }

    // MARK: - Form

    private var reportForm: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    photoSection
                    stationCard
                    if case .failure(let msg) = viewModel.state {
                        Text(msg)
                            .font(.caption).foregroundStyle(.red)
                            .padding(.horizontal, TaggoSpacing.horizontalPadding)
                    }
                    Spacer(minLength: 100)
                }
                .padding(.top, 16)
            }
            .scrollIndicators(.hidden)
            .background(Color.taggoBackground)

            submitBar
        }
    }

    // MARK: Header

    private var headerCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "hands.clap.fill")
                .font(.title2).foregroundStyle(Color.taggoBlue)
            VStack(alignment: .leading, spacing: 2) {
                Text("You found someone's item!")
                    .font(.subheadline).fontWeight(.bold)
                Text("Fill in where you found it so the owner can claim it.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.taggoBlueLight.opacity(0.4) as Color)
        .clipShape(RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius))
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
    }

    // MARK: Photo

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Photo (optional)")
                .font(.caption).foregroundStyle(.secondary)
                .padding(.horizontal, TaggoSpacing.horizontalPadding)

            let photoData = viewModel.selectedPhotoData
            let blue = Color("TaggoBlue")
            PhotosPicker(selection: $photosPickerItem, matching: .images) {
                GeometryReader { proxy in
                    Group {
                        if let data = photoData, let img = UIImage(data: data) {
                            Image(uiImage: img).resizable().scaledToFill()
                        } else {
                            Color(.systemGray5)
                                .overlay {
                                    VStack(spacing: 8) {
                                        Image(systemName: "camera.fill")
                                            .font(.title2)
                                            .foregroundStyle(blue.opacity(0.6))
                                        Text("Add Photo").font(.caption)
                                            .foregroundStyle(blue)
                                    }
                                }
                        }
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, TaggoSpacing.horizontalPadding)
            .onChange(of: photosPickerItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        viewModel.selectedPhotoData = data
                    }
                }
            }
        }
    }

    // MARK: Station + Note fields

    private var stationCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(Color.taggoBlue).font(.title3).frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Found at *").font(.caption).foregroundStyle(.secondary)
                    TextField("Station or location name", text: $viewModel.station)
                        .font(.subheadline)
                }
            }
            .padding(.horizontal, TaggoSpacing.horizontalPadding)
            .padding(.vertical, 14)

            Divider().padding(.leading, 44 + TaggoSpacing.horizontalPadding)

            HStack(spacing: 12) {
                Image(systemName: "pencil.circle.fill")
                    .foregroundStyle(Color.taggoBlue).font(.title3).frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Note (optional)").font(.caption).foregroundStyle(.secondary)
                    TextField("Any extra info for the owner", text: $viewModel.note)
                        .font(.subheadline)
                }
            }
            .padding(.horizontal, TaggoSpacing.horizontalPadding)
            .padding(.vertical, 14)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: TaggoSpacing.cardCornerRadius))
        .padding(.horizontal, TaggoSpacing.horizontalPadding)
    }

    // MARK: Submit bar

    private var submitBar: some View {
        VStack(spacing: 0) {
            Divider()
            Button {
                Task { await viewModel.submit() }
            } label: {
                Group {
                    if viewModel.state == .submitting {
                        ProgressView().tint(.white)
                    } else {
                        Text("Submit Report").font(Font.headline)
                    }
                }
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.taggoBlue)
                .clipShape(Capsule())
            }
            .disabled(viewModel.state == .submitting || viewModel.station.isEmpty)
            .padding(.horizontal, TaggoSpacing.horizontalPadding)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
        }
    }

    // MARK: - Success

    private var reportSuccess: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color.taggoBlue)

            Text("Thanks for helping!")
                .font(.title2).fontWeight(.bold)
                .padding(.top, 20)

            Text("The owner has been notified. They'll see your report in their inbox.")
                .font(.subheadline).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 8)

            Spacer()

            Button(action: { onFinished?() }) {
                Text("Done")
                    .font(Font.headline).foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.taggoBlue)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, TaggoSpacing.horizontalPadding)
            .padding(.bottom, 40)
        }
        .background(Color.taggoBackground.ignoresSafeArea())
    }
}

#Preview {
    let vm = ReportFormViewModel(
        itemID: UUID(),
        reportFoundItemUseCase: AppDependencies.live.makeReportFoundItemUseCase()
    )
    ReportFormView(viewModel: vm)
}
