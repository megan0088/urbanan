//
//  ClipDependencies.swift
//  TaggoClip
//
//  Created by Xaviero Yamin Loganta on 06/07/26.
//

import Foundation

struct ClipDependencies {
    let cloudKitManager: CloudKitManaging
    let imageCompressor: ImageCompressing
 
    static let live = ClipDependencies(
        cloudKitManager: CloudKitManager(),
        imageCompressor: ImageCompressor()
    )
 
    func makeResolveScannedItemUseCase() -> ResolveScannedItemUseCase {
        ResolveScannedItemUseCase(cloudKitManager: cloudKitManager)
    }
 
    func makeReportFoundItemUseCase() -> ReportFoundItemUseCase {
        ReportFoundItemUseCase(
            foundReportSubmitting: HTTPFoundReportSubmitter(),
            imageCompressor: imageCompressor
        )
    }
}
