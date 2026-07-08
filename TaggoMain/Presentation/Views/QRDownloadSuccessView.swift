//
//  QRDownloadSuccessView.swift
//  TaggoMain
//

import SwiftUI

struct QRDownloadSuccessView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            checkmarkIcon
                .padding(.bottom, 24)

            Text("QR Code was downloaded!")
                .font(.title2).fontWeight(.bold)
                .foregroundStyle(Color(.label))
                .padding(.bottom, 8)

            Text("Image saved to your gallery")
                .font(.body)
                .foregroundStyle(Color(.secondaryLabel))

            Spacer()

            bottomSection
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(.label))
                        .frame(width: 40, height: 40)
                        .background(Color(.secondarySystemFill))
                        .clipShape(Circle())
                }
            }
        }
    }

    // MARK: - Checkmark

    private var checkmarkIcon: some View {
        ZStack {
            Circle()
                .fill(Color.green.opacity(0.15))
                .frame(width: 100, height: 100)

            Circle()
                .fill(Color.green)
                .frame(width: 64, height: 64)

            Image(systemName: "checkmark")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    // MARK: - Bottom

    private var bottomSection: some View {
        ZStack(alignment: .bottomTrailing) {
            Image("QRDownloadedIllustration")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(.trailing, 10)

            Text("Print the QR code and stick it on your item immediately. So that if your item is lost, the person who finds it can notify you.")
                .font(.callout)
                .foregroundStyle(Color(.secondaryLabel))
                .lineSpacing(4)
                .frame(width: 230, alignment: .leading)
                .padding(.bottom, 150)
                .padding(.trailing, 140)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.leading, 20)
    }
}

#Preview {
    NavigationStack {
        QRDownloadSuccessView()
    }
}
