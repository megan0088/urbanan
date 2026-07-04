//
//  ItemDetailView.swift
//  TaggoMain
//
//  Created by Xaviero Yamin Loganta on 05/07/26.
//

import Foundation
import SwiftUI

struct ItemDetailView: View {
    let item: Item
    @Environment(\.dismiss) private var dismiss
 
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
                LabeledContent("Registered", value: item.createdAt.formatted(date: .abbreviated, time: .shortened))
            }
            .navigationTitle(item.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
