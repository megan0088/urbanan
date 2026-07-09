//
//  AppClipPreviewHost.swift
//  TaggoMain
//
//  Preview host for TaggoClip UI screens.
//  App Clip targets don't support JIT preview linking,
//  so these views live here (TaggoMain) for canvas rendering only.
//

#if DEBUG
import SwiftUI
import PhotosUI

private enum ClipPreviewSpacing {
    static let horizontal: CGFloat = 24
    static let cardCorner: CGFloat = 16
}

// MARK: - Welcome Screen

private struct AppClipWelcomePreview: View {
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
                    .padding(.horizontal, ClipPreviewSpacing.horizontal)
                    .padding(.top, 12)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))

            VStack(spacing: 0) {
                Divider()
                Text("Continue")
                    .font(.headline).foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.taggoBlue)
                    .clipShape(Capsule())
                    .padding(.horizontal, ClipPreviewSpacing.horizontal)
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
            }
        }
    }
}

// MARK: - Form Screen

private struct AppClipFormPreview: View {
    @State private var station = "Stasiun Gambir"
    @State private var note = "Saya menemukan tas ini di rak bagasi atas."
    @State private var photosPickerItem: PhotosPickerItem?

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("A few details, please.")
                        .font(.title2).fontWeight(.bold)
                        .padding(.horizontal, ClipPreviewSpacing.horizontal)
                        .padding(.top, 24)

                    Text("Help the owner recognize where and how you found this item")
                        .font(.subheadline).foregroundStyle(.secondary)
                        .padding(.horizontal, ClipPreviewSpacing.horizontal)
                        .padding(.top, 4)
                        .padding(.bottom, 24)

                    // Location field
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 10) {
                            Image(systemName: "mappin.circle")
                                .font(.title3).foregroundStyle(Color.taggoBlue).frame(width: 28)
                            Text("Location").font(.subheadline).fontWeight(.semibold)
                        }
                        .padding(.horizontal, ClipPreviewSpacing.horizontal)

                        HStack {
                            TextField("Where did you find it?", text: $station).font(.subheadline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption).fontWeight(.semibold).foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, ClipPreviewSpacing.horizontal)
                        .padding(.vertical, 14)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: ClipPreviewSpacing.cardCorner))
                        .padding(.horizontal, ClipPreviewSpacing.horizontal)
                    }
                    .padding(.bottom, 16)

                    // Notes field
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 10) {
                            Image(systemName: "pencil.circle")
                                .font(.title3).foregroundStyle(Color.taggoBlue).frame(width: 28)
                            Text("Notes").font(.subheadline).fontWeight(.semibold)
                        }
                        .padding(.horizontal, ClipPreviewSpacing.horizontal)

                        TextField("Leave some notes for owner...", text: $note, axis: .vertical)
                            .font(.subheadline).lineLimit(3...5)
                            .padding(.horizontal, ClipPreviewSpacing.horizontal)
                            .padding(.vertical, 14)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: ClipPreviewSpacing.cardCorner))
                            .padding(.horizontal, ClipPreviewSpacing.horizontal)
                    }
                    .padding(.bottom, 16)

                    // Photo picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Photo")
                            .font(.subheadline).fontWeight(.semibold)
                            .padding(.horizontal, ClipPreviewSpacing.horizontal)

                        PhotosPicker(selection: $photosPickerItem, matching: .images) {
                            Color(.systemBackground)
                                .overlay {
                                    VStack(spacing: 8) {
                                        Image(systemName: "camera.fill")
                                            .font(.title2)
                                            .foregroundStyle(Color.taggoBlue.opacity(0.5))
                                        Text("Add photo")
                                            .font(.subheadline).fontWeight(.medium)
                                            .foregroundStyle(Color.taggoBlue)
                                        Text("Please take a photo of the item")
                                            .font(.caption)
                                            .foregroundStyle(Color.taggoBlue.opacity(0.7))
                                    }
                                }
                                .frame(maxWidth: .infinity).frame(height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: ClipPreviewSpacing.cardCorner))
                                .overlay(
                                    RoundedRectangle(cornerRadius: ClipPreviewSpacing.cardCorner)
                                        .strokeBorder(Color.taggoBlue.opacity(0.5),
                                                      style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                                )
                        }
                        .padding(.horizontal, ClipPreviewSpacing.horizontal)
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
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.taggoBlue)
                    .clipShape(Capsule())
                    .padding(.horizontal, ClipPreviewSpacing.horizontal)
                    .padding(.top, 12).padding(.bottom, 4)
                Text("Your report is secure and confidential.")
                    .font(.caption2).foregroundStyle(.tertiary)
                    .padding(.bottom, 12)
            }
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Success Screen

private struct AppClipSuccessPreview: View {
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
                .padding(.horizontal, ClipPreviewSpacing.horizontal)
                .padding(.top, 10)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Error Screen

private struct AppClipErrorPreview: View {
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

#Preview("AppClip — Welcome") {
    AppClipWelcomePreview()
}

#Preview("AppClip — Form") {
    AppClipFormPreview()
}

#Preview("AppClip — Success") {
    AppClipSuccessPreview()
}

#Preview("AppClip — Error") {
    AppClipErrorPreview(message: "We couldn't find this item. Make sure you're scanning the correct QR code.")
}
#endif
