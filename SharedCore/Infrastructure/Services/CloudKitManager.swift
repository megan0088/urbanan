//
//  CloudKitManager.swift
//  SharedCore
//

import Foundation
import CloudKit

final class CloudKitManager: CloudKitManaging {
    private let database: CKDatabase
    
    init(database: CKDatabase = CKContainer.default().publicCloudDatabase) {
        self.database = database
    }
    
    func saveItem(_ item: Item) async throws -> Item {
        let record = ItemMapper.toRecord(item: item)
        do  {
            let savedRecord = try await database.save(record)
            return try ItemMapper.toItem(record: savedRecord)
        } catch let error as CKError {
            throw Self.map(error)
        }
    }
    
    private static func map(_ error: CKError) -> TaggoError {
        switch error.code {
        case .networkUnavailable, .networkFailure:
            return .networkUnavailable
        case .unknownItem:
            return .notFound
        case .permissionFailure, .notAuthenticated:
            return .unauthorized
        case .quotaExceeded:
            return .quotaExceeded
        default:
            return .unknown(error.localizedDescription)
        }
    }
}
