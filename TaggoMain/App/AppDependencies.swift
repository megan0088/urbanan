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
            resolveScannedItemUC: ResolveScannedItemUseCase(cloudKitManager: cloudKitManager),
            reportFoundItemUseCase: makeReportFoundItemUseCase()
        )
    }
    
    func makeResolveScannedItemUseCase() -> ResolveScannedItemUseCase {
        ResolveScannedItemUseCase(cloudKitManager: cloudKitManager)
    }
    
    func makeReportFoundItemUseCase() -> ReportFoundItemUseCase {
        ReportFoundItemUseCase(cloudKitManager: cloudKitManager, imageCompressor: imageCompressor)
    }
    
    func makeItemDetailViewModel(item: Item) -> ItemDetailViewModel {
        ItemDetailViewModel(item: item, deleteItemUseCase: makeDeleteItemUseCase(), qrManager: qrManager)
    }
    
    func makeEditItemViewModel(item: Item) -> EditItemViewModel {
        EditItemViewModel(item: item, editItemUseCase: makeEditItemUseCase())
    }
    
    func makeEditItemUseCase() -> EditItemUseCase {
        EditItemUseCase(
            cloudKitManager: cloudKitManager,
            currentUserProvider: currentUserProvider,
            imageCompressor: imageCompressor
        )
    }
 
    func makeDeleteItemUseCase() -> DeleteItemUseCase {
        DeleteItemUseCase(cloudKitManager: cloudKitManager, currentUserProvider: currentUserProvider)
    }
}
