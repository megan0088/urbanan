//
//  DeleteItemUseCase.swift
//  SharedCore
//
import Foundation

struct DeleteItemUseCase {
    private let cloudKitManager: CloudKitManaging
    private let currentUserProvider: CurrentUserProviding

    init(cloudKitManager: CloudKitManaging, currentUserProvider: CurrentUserProviding) {
        self.cloudKitManager = cloudKitManager
        self.currentUserProvider = currentUserProvider
    }

    func execute(itemID: UUID) async throws {
        let existing = try await cloudKitManager.fetchItem(id: itemID)

        guard existing.ownerID == currentUserProvider.currentUserID else {
            throw TaggoError.notOwner
        }

        try await cloudKitManager.deleteItem(id: itemID)
    }
}
