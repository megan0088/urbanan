//
//  ScannedItemView.swift
//  TaggoMain
//
//  Created by Xaviero Yamin Loganta on 06/07/26.
//

import SwiftUI

struct ScannedItemView: View {
    let item: Item
    var onReportTapped: () -> Void
    var onDismiss: (() -> Void)?

    var body: some View {
        NavigationStack {
            Form {
                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                }
                LabeledContent("Name", value: item.name)
                LabeledContent("Category", value: item.category)
                LabeledContent("Color", value: item.color)
                if let description = item.description, !description.isEmpty {
                    LabeledContent("Description", value: description)
                }

                Section {
                    Button("Report Found") {
                        onReportTapped()
                    }
                }
            }
            .navigationTitle(item.name)
            .toolbar {
                if let onDismiss {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Scan Again") { onDismiss() }
                    }
                }
            }
        }
    }
}
