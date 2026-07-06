//
//  MockCloudKitManager.swift
//  TaggoTests
//

import Foundation

final class MockCloudKitManager: CloudKitManaging, @unchecked Sendable {
    var saveItemResult: Result<Item, Error>?
    private(set) var saveItemCount = 0
    private(set) var lastSavedItem: Item?

    var fetchItemResult: Result<Item, Error>?
    private(set) var fetchItemCount = 0
    private(set) var lastFetchedItemID: UUID?

    var fetchItemsResult: Result<[Item], Error> = .success([])
    private(set) var fetchItemsCount = 0
    private(set) var lastFetchItemsOwnerID: UUID?

    func saveItem(_ item: Item) async throws -> Item {
        saveItemCount += 1
        lastSavedItem = item

        switch saveItemResult {
        case .success(let overrideItem):
            return overrideItem
        case .failure(let error):
            throw error
        case .none:
            return item
        }
    }

    func fetchItem(id: UUID) async throws -> Item {
        fetchItemCount += 1
        lastFetchedItemID = id

        guard let fetchItemResult else {
            throw TaggoError.notFound
        }
        switch fetchItemResult {
        case .success(let item):
            return item
        case .failure(let error):
            throw error
        }
    }

    func fetchItems(ownedBy ownerID: UUID) async throws -> [Item] {
        fetchItemsCount += 1
        lastFetchItemsOwnerID = ownerID

        switch fetchItemsResult {
        case .success(let items):
            return items
        case .failure(let error):
            throw error
        }
    }
}
