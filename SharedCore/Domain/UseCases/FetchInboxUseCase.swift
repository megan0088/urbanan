//
//  FetchInboxUseCase.swift
//  SharedCore
//

import Foundation

struct FetchInboxUseCase {
    private let cloudKitManager: CloudKitManaging
    private let currentUserProvider: CurrentUserProviding

    init(cloudKitManager: CloudKitManaging, currentUserProvider: CurrentUserProviding) {
        self.cloudKitManager = cloudKitManager
        self.currentUserProvider = currentUserProvider
    }

    func execute() async throws -> [FoundReport] {
        let ownedItems = try await cloudKitManager.fetchItems(ownedBy: currentUserProvider.currentUserID)
        guard !ownedItems.isEmpty else { return [] }

        let reports = try await cloudKitManager.fetchFoundReports(forItemIDs: ownedItems.map(\.id))
        return reports.sorted { $0.reportedAt > $1.reportedAt }
    }
}
