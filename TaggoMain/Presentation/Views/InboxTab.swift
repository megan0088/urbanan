//
//  InboxTab.swift
//  TaggoMain
//

import SwiftUI

struct InboxTab: View {
    let dependencies: AppDependencies
    @State private var viewModel: InboxViewModel

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _viewModel = State(initialValue: dependencies.makeInboxViewModel())
    }

    var body: some View {
        InboxView(viewModel: viewModel, dependencies: dependencies)
    }
}

#Preview {
    InboxTab(dependencies: .live)
}
