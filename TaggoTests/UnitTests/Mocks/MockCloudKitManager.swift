import Foundation

final class MockCloudKitManager: CloudKitManaging, @unchecked Sendable {
    var saveItemResult: Result<Item, Error>?
    private(set) var saveItemCallCount = 0
    private(set) var lastSavedItem: Item?

    var fetchItemResult: Result<Item, Error>?
    private(set) var fetchItemCallCount = 0
    private(set) var lastFetchedItemID: UUID?

    var fetchItemsResult: Result<[Item], Error>?
    private(set) var fetchItemsCallCount = 0
    private(set) var lastFetchItemsOwnerID: UUID?

    var saveFoundReportResult: Result<FoundReport, Error>?
    private(set) var saveFoundReportCallCount = 0
    private(set) var lastSavedFoundReport: FoundReport?

    func saveItem(_ item: Item) async throws -> Item {
        saveItemCallCount += 1
        lastSavedItem = item
        switch saveItemResult {
        case .success(let overrideItem): return overrideItem
        case .failure(let error): throw error
        case .none: return item
        }
    }

    func fetchItem(id: UUID) async throws -> Item {
        fetchItemCallCount += 1
        lastFetchedItemID = id
        switch fetchItemResult {
        case .success(let item): return item
        case .failure(let error): throw error
        case .none: throw TaggoError.notFound
        }
    }

    func fetchItems(ownedBy ownerID: UUID) async throws -> [Item] {
        fetchItemsCallCount += 1
        lastFetchItemsOwnerID = ownerID
        switch fetchItemsResult {
        case .success(let items): return items
        case .failure(let error): throw error
        case .none: return []
        }
    }

    func saveFoundReport(_ report: FoundReport) async throws -> FoundReport {
        saveFoundReportCallCount += 1
        lastSavedFoundReport = report
        switch saveFoundReportResult {
        case .success(let overrideReport): return overrideReport
        case .failure(let error): throw error
        case .none: return report
        }
    }
}
