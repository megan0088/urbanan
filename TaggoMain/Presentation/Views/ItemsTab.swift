//
//  ItemsTab.swift
//  TaggoMain
//

import Foundation
import SwiftUI

private enum ItemsRoute: Hashable {
    case register
    case inbox
    case scan
}

struct ItemsTab: View {
    private let dependencies: AppDependencies
    @State private var viewModel: ItemListViewModel
    @State private var inboxViewModel: InboxViewModel
    @State private var scanViewModel: ScanViewModel
    @State private var path = NavigationPath()

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _viewModel = .init(initialValue: dependencies.makeItemListViewModel())
        _inboxViewModel = .init(initialValue: dependencies.makeInboxViewModel())
        _scanViewModel = .init(initialValue: dependencies.makeScanViewModel())
    }

    var body: some View {
        NavigationStack(path: $path) {
            ItemListView(
                dependencies: dependencies,
                viewModel: viewModel,
                inboxViewModel: inboxViewModel,
                onAddTapped: { path.append(ItemsRoute.register) },
                onScanTapped: {
                    scanViewModel.reset()
                    path.append(ItemsRoute.scan)
                },
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
                case .scan:
                    ScannerView(viewModel: scanViewModel, dependencies: dependencies)
                        .navigationTitle("Scan")
                        .navigationBarTitleDisplayMode(.inline)
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
