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
    let notificationManaging: NotificationManaging
    let photoLibrarySaving: PhotoLibrarySaving

    static let live = AppDependencies(
        cloudKitManager: CloudKitManager(),
        qrManager: QRManager(),
        currentUserProvider: CurrentUserProvider(),
        imageCompressor: ImageCompressor(),
        notificationManaging: NotificationManager(),
        photoLibrarySaving: PhotoLibrarySaver()
    )

    func makeRegisterViewModel() -> RegisterViewModel {
        RegisterViewModel(
            registerItemUseCase: RegisterItemUseCase(
                cloudKitManager: cloudKitManager,
                qrManager: qrManager,
                currentUserProvider: currentUserProvider,
                imageCompressor: imageCompressor,
                notificationManaging: notificationManaging
            ),
            photoLibrarySaving: photoLibrarySaving
        )
    }

    func makeInboxViewModel() -> InboxViewModel {
        InboxViewModel(
            fetchInboxUseCase: FetchInboxUseCase(cloudKitManager: cloudKitManager, currentUserProvider: currentUserProvider),
            markReportClaimedUseCase: MarkReportClaimedUseCase(cloudKitManager: cloudKitManager),
            markReportReadUseCase: MarkReportReadUseCase(cloudKitManager: cloudKitManager),
            foundReportEvents: notificationManaging.foundReportEvents
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
            currentUserProvider: currentUserProvider,
            reportFoundItemUseCase: makeReportFoundItemUseCase()
        )
    }
    
    func makeResolveScannedItemUseCase() -> ResolveScannedItemUseCase {
        ResolveScannedItemUseCase(cloudKitManager: cloudKitManager)
    }
    
    func makeReportFoundItemUseCase() -> ReportFoundItemUseCase {
        ReportFoundItemUseCase(
            foundReportSubmitting: CloudKitFoundReportSubmitter(cloudKitManager: cloudKitManager),
            imageCompressor: imageCompressor
        )
    }
    
    func makeItemDetailViewModel(item: Item) -> ItemDetailViewModel {
        ItemDetailViewModel(
            item: item,
            deleteItemUseCase: makeDeleteItemUseCase(),
            qrManager: qrManager,
            photoLibrarySaving: photoLibrarySaving
        )
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
