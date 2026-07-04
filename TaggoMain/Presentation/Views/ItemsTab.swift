//
//  ItemsTab.swift
//  TaggoMain
//
//  Created by Xaviero Yamin Loganta on 05/07/26.
//

import Foundation
import SwiftUI

private enum ItemsRoute: Hashable {
    case register
}

struct ItemsTab: View {
    private let dependencies: AppDependencies
    @State private var viewModel: ItemListViewModel
    @State private var path = NavigationPath()
    
    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _viewModel = .init(initialValue: dependencies.makeItemListViewModel())
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ItemListView(viewModel: viewModel)
                .navigationTitle("My Items")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            path.append(ItemsRoute.register)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .navigationDestination(for: ItemsRoute.self) { route in
                    switch route {
                    case .register:
                        RegisterView(viewModel: dependencies.makeRegisterViewModel(), onFinished: { path.removeLast() });
                    }
                }
        }
    }
}
