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
 
    static let live = AppDependencies(
        cloudKitManager: CloudKitManager(),
        qrManager: QRManager(),
        currentUserProvider: CurrentUserProvider()
    )
 
    func makeRegisterViewModel() -> RegisterViewModel {
        RegisterViewModel(
            registerItemUseCase: RegisterItemUseCase(
                cloudKitManager: cloudKitManager,
                qrManager: qrManager,
                currentUserProvider: currentUserProvider
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
 
//    func makeScanViewModel() -> ScanViewModel {
//        ScanViewModel(
//            resolveScannedItemUseCase: ResolveScannedItemUseCase(cloudKitManager: cloudKitManager)
//        )
//    }
}
