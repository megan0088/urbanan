//
//  RegisterView.swift
//  TaggoMain
//

import SwiftUI

struct RegisterView: View {
    @State private var viewModel: RegisterViewModel
    var onFinished: (() -> Void)?
 
    init(viewModel: RegisterViewModel, onFinished: (() -> Void)? = nil) {
        _viewModel = State(initialValue: viewModel)
        self.onFinished = onFinished
    }
 
    var body: some View {
        Form {
            Section("Item Details") {
                TextField("Name", text: $viewModel.name)
                TextField("Category", text: $viewModel.category)
                TextField("Color", text: $viewModel.color)
                TextField("Description", text: $viewModel.description)
            }
            
            Section {
                Button("Register Item") {
                    Task { await viewModel.submit() }
                }
                .disabled(viewModel.state == .loading)
            }
            
            Section {
                switch viewModel.state {
                case .idle:
                    EmptyView()
                case .loading:
                    ProgressView("Registering…")
                case .success(let qrData):
                    if let uiImage = UIImage(data: qrData) {
                        VStack {
                            Text("Registered! Print this QR:")
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 200, height: 200)
                        }
                    }
                case .failure(let message):
                    Text(message).foregroundStyle(.red)
                }
            }
        }
    }
}
 
