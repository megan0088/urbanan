//
//  ContentView.swift
//  urbanan
//
//  Created by Muhamad Ega Nugraha on 02/07/26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(viewModel.message)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
