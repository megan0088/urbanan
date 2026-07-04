//
//  MockCloudKitManager.swift
//  TaggoTests
//

import Foundation

final class MockCloudKitManager: CloudKitManaging, @unchecked Sendable {
    var saveItemResult: Result<Item, Error>?
    private(set) var saveItemCount = 0;
    private var lastSavedItem: Item?
    
    func saveItem(_ item: Item) async throws -> Item {
        saveItemCount += 1
        lastSavedItem = item
        
        switch saveItemResult {
        case.success(let overrideItem):
            return overrideItem
        case .failure(let error):
            throw error
        case .none:
            return item
        }
    }
}
