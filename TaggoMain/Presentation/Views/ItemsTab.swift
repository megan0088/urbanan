//
//  ItemsTab.swift
//  TaggoMain
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
            ItemListView(
                dependencies: dependencies,
                viewModel: viewModel,
                onAddTapped: { path.append(ItemsRoute.register) }
            )
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ItemsRoute.self) { route in
                switch route {
                case .register:
                    RegisterView(
                        viewModel: dependencies.makeRegisterViewModel(),
                        onFinished: { path.removeLast() }
                    )
                }
            }
        }
    }
}

#Preview {
    ItemsTab(dependencies: .live)
}
