//
//  RootTabView.swift
//  TaggoMain
//
//  Created by Xaviero Yamin Loganta on 05/07/26.
//

import Foundation
import SwiftUI

struct RootTabView: View {
    let dependencies: AppDependencies
    
    var body: some View {
        TabView {
            ItemsTab(dependencies: dependencies)
                .tabItem {
                    Label("Items", systemImage: "rectangle.stack")
                }
            
            
            
        }
    }
}
