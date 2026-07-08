//
//  ScannedItemFlowView.swift
//  TaggoMain
//
//  Created by Xaviero Yamin Loganta on 06/07/26.
//

import Foundation
import SwiftUI

private extension Item {
    static var previewScanned: Item {
        Item(id: UUID(), ownerID: UUID(), name: "Blue Backpack", category: "Bag",
             color: "Navy Blue", description: "A worn navy blue backpack with laptop compartment",
             imageData: nil, createdAt: Date(), updatedAt: Date())
    }
}

struct ScannedItemFlowView: View {
    let item: Item
    let reportFoundItemUseCase: ReportFoundItemUseCase
    var onDismiss: (() -> Void)?
 
    @State private var isReporting = false
 
    var body: some View {
        if isReporting {
            ReportFormView(
                viewModel: ReportFormViewModel(itemID: item.id, reportFoundItemUseCase: reportFoundItemUseCase),
                onFinished: { onDismiss?() }
            )
        } else {
            ScannedItemView(
                item: item,
                onReportTapped: { isReporting = true },
                onDismiss: onDismiss
            )
        }
    }
}

#Preview("Step 1 — Found Item") {
    ScannedItemFlowView(
        item: .previewScanned,
        reportFoundItemUseCase: AppDependencies.live.makeReportFoundItemUseCase()
    )
}

#Preview("Step 2 — Report Form") {
    ReportFormView(
        viewModel: ReportFormViewModel(
            itemID: UUID(),
            reportFoundItemUseCase: AppDependencies.live.makeReportFoundItemUseCase()
        )
    )
}
