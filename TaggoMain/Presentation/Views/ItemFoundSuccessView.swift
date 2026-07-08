//
//  ItemFoundSuccessView.swift
//  TaggoMain
//

import SwiftUI

struct ItemFoundSuccessView: View {
    var onDismiss: (() -> Void)?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            handsIllustration

            Text("Item found!!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 28)

            Text("Great news! You've successfully collected your item.")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
                .padding(.top, 12)

            Spacer()

            doneButton
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    private var handsIllustration: some View {
        HStack(spacing: 4) {
            Image(systemName: "hand.wave.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(.taggoBlue)
                .scaleEffect(CGSize(width: -1, height: 1))
                .rotationEffect(.degrees(-15))

            Image(systemName: "hand.wave.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(.taggoBlueLight)
                .rotationEffect(.degrees(15))
        }
    }

    private var doneButton: some View {
        Button(action: handleDismiss) {
            Text("Done")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.taggoBlue)
                .foregroundStyle(Color.white)
                .clipShape(Capsule())
        }
    }

    private func handleDismiss() {
        if let handler = onDismiss {
            handler()
        } else {
            dismiss()
        }
    }
}

#Preview {
    ItemFoundSuccessView()
}
