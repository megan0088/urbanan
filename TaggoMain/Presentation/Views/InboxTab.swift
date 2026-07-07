//
//  InboxTab.swift
//  TaggoMain
//

import SwiftUI

struct InboxTab: View {
    @State private var viewModel: InboxViewModel

    init(dependencies: AppDependencies) {
        _viewModel = State(initialValue: dependencies.makeInboxViewModel())
    }

    var body: some View {
        NavigationStack {
            InboxView(viewModel: viewModel)
                .navigationTitle("Inbox")
        }
    }
}
