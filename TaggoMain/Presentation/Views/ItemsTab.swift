//
//  ItemsTab.swift
//  TaggoMain
//

import Foundation
import SwiftUI

private enum ItemsRoute: Hashable {
    case register
    case inbox
}

struct ItemsTab: View {
    private let dependencies: AppDependencies
    @State private var viewModel: ItemListViewModel
    @State private var inboxViewModel: InboxViewModel
    @State private var path = NavigationPath()

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _viewModel = .init(initialValue: dependencies.makeItemListViewModel())
        _inboxViewModel = .init(initialValue: dependencies.makeInboxViewModel())
    }

    private var hasUnread: Bool {
        if case .loaded(let reports) = inboxViewModel.state {
            return reports.contains { !$0.isRead }
        }
        return false
    }

    var body: some View {
        NavigationStack(path: $path) {
            ItemListView(
                dependencies: dependencies,
                viewModel: viewModel,
                hasUnread: hasUnread,
                onAddTapped: { path.append(ItemsRoute.register) },
                onBellTapped: { path.append(ItemsRoute.inbox) }
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
                case .inbox:
                    InboxView(viewModel: inboxViewModel, dependencies: dependencies)
                }
            }
        }
        .task { await inboxViewModel.load() }
        .task { await inboxViewModel.observeFoundReportEvents() }
    }
}

#Preview {
    ItemsTab(dependencies: .live)
}
