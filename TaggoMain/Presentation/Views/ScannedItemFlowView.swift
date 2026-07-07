//
//  ScannedItemFlowView.swift
//  TaggoMain
//
//  Created by Xaviero Yamin Loganta on 06/07/26.
//

import Foundation
import SwiftUI

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
