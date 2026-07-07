//
//  ResolveScannedItemUseCase.swift
//  urbanan
//
//  Created by Xaviero Yamin Loganta on 06/07/26.
//

import Foundation

struct ResolveScannedItemUseCase {
    private let cloudKitManager: CloudKitManaging
    
    init(cloudKitManager: CloudKitManaging) {
        self.cloudKitManager = cloudKitManager
    }
    
    func execute(scannedString: String) async throws -> Item {
        guard let url = URL(string: scannedString),
              let itemID = UniversalLinkParser.itemID(from: url)
        else { throw TaggoError.invalidLink(scannedString) }
        return try await cloudKitManager.fetchItem(id: itemID);
    }
}

