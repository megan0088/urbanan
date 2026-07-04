//
//  ListItemsUseCase.swift
//  SharedCore
//

import Foundation

struct ListItemsUseCase {
    private let cloudKitManager: CloudKitManaging
    private let currentUserProvider: CurrentUserProviding
    
    init(cloudKitManager: CloudKitManaging, currentUserProvider: CurrentUserProviding) {
        self.cloudKitManager = cloudKitManager
        self.currentUserProvider = currentUserProvider
    }
    
    func execute() async throws -> [Item] {
        try await cloudKitManager.fetchItems(ownedBy: currentUserProvider.currentUserID)
    }
}
