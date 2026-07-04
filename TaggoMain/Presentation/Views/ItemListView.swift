//
//  ItemListView.swift
//  TaggoMain
//
//  Created by Xaviero Yamin Loganta on 05/07/26.
//

import Foundation
import SwiftUI

struct ItemListView: View {
    @State private var viewModel: ItemListViewModel
    @State private var selectedItem: Item?
 
    init(viewModel: ItemListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
 
    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]
 
    var body: some View {
        ScrollView {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
                    .padding()
            case .loaded(let items):
                if items.isEmpty {
                    Text("No items registered yet.")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(items) { item in
                            Button {
                                selectedItem = item
                            } label: {
                                ItemCardView(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            case .failure(let message):
                Text(message).foregroundStyle(.red).padding()
            }
        }
        .onAppear {
            Task { await viewModel.load() }
        }
        .refreshable {
            await viewModel.load()
        }
        .sheet(item: $selectedItem) { item in
            ItemDetailView(item: item)
        }
    }
}
 
private struct ItemCardView: View {
    let item: Item
 
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 100)
                    .clipped()
            } else {
                Rectangle()
                    .fill(.gray.opacity(0.2))
                    .frame(height: 100)
            }
            Text(item.name).font(.headline).lineLimit(1)
            Text(item.category).font(.caption).foregroundStyle(.secondary)
        }
        .padding(8)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 1)
    }
}
