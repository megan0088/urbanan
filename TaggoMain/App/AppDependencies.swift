//
//  AppDependencies.swift
//  TaggoMain
//
//  Created by Xaviero Yamin Loganta on 05/07/26.
//

import Foundation


struct AppDependencies {
    let cloudKitManager: CloudKitManaging
    let qrManager: QRManaging
    let currentUserProvider: CurrentUserProviding
    let imageCompressor: ImageCompressing
    
    static let live = AppDependencies(
        cloudKitManager: CloudKitManager(),
        qrManager: QRManager(),
        currentUserProvider: CurrentUserProvider(),
        imageCompressor: ImageCompressor(),
    )
 
    func makeRegisterViewModel() -> RegisterViewModel {
        RegisterViewModel(
            registerItemUseCase: RegisterItemUseCase(
                cloudKitManager: cloudKitManager, qrManager: qrManager, currentUserProvider: currentUserProvider, imageCompressor: imageCompressor
            )
        )
    }
 
    func makeItemListViewModel() -> ItemListViewModel {
        ItemListViewModel(
            listItemsUseCase: ListItemsUseCase(
                cloudKitManager: cloudKitManager,
                currentUserProvider: currentUserProvider
            )
        )
    }
 
    func makeScanViewModel() -> ScanViewModel {
        ScanViewModel(
            resolveScannedItemUC: ResolveScannedItemUseCase(cloudKitManager: cloudKitManager)
        )
    }
    
    func makeResolveScannedItemUseCase() -> ResolveScannedItemUseCase {
        ResolveScannedItemUseCase(cloudKitManager: cloudKitManager)
    }
}
