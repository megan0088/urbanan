//
//  CloudKitManager.swift
//  SharedCore
//

import Foundation
import CloudKit

final class CloudKitManager: CloudKitManaging {
    private let database: CKDatabase
    
    init(database: CKDatabase = CKContainer(identifier: AppConfiguration.cloudKitContainerIdentifier).publicCloudDatabase) {
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
    
    func fetchItem(id: UUID) async throws -> Item {
        let recordID = CKRecord.ID(recordName: id.uuidString)
        do {
            let record = try await database.record(for: recordID)
            return try ItemMapper.toItem(record: record)
        } catch let error as CKError {
            throw Self.map(error)
        }
    }
    
    func fetchItems(ownedBy ownerID: UUID) async throws -> [Item] {
        let predicate = NSPredicate(format: "%K == %@", RecordSchema.Item.Field.ownerID, ownerID.uuidString)
        let query = CKQuery(recordType: RecordSchema.Item.recordType, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: RecordSchema.Item.Field.createdAt, ascending: false)]
        
        do {
            var items: [Item] = []
            var cursor: CKQueryOperation.Cursor?
            repeat {
                let matchResults: [(CKRecord.ID, Result<CKRecord, Error>)]
                let nextCursor: CKQueryOperation.Cursor?
                if let cursor {
                    (matchResults, nextCursor) = try await database.records(continuingMatchFrom: cursor)
                }
                else {
                    (matchResults, nextCursor) = try await database.records(matching: query)
                }
                
                for(_, result) in matchResults {
                    if case .success(let record) = result {
                        items.append(try ItemMapper.toItem(record: record))
                    }
                }
                cursor = nextCursor
            } while cursor != nil
            
            return items
        } catch let error as CKError {
            throw Self.map(error)
        }
    }
    
    func deleteItem(id: UUID) async throws {
        do {
            let recordID = CKRecord.ID(recordName: id.uuidString)
            _ = try await database.deleteRecord(withID: recordID)
        } catch let error as CKError {
            throw Self.map(error)
        }
    }
    
    func updateItem(_ item: Item) async throws -> Item {
        do {
            let recordID = CKRecord.ID(recordName: item.id.uuidString)
            let existingRecord = try await database.record(for: recordID)
            let updatedRecord = ItemMapper.toRecord(item: item, existingRecord: existingRecord)
            let savedRecord = try await database.save(updatedRecord)
            return try ItemMapper.toItem(record: savedRecord)
        } catch let error as CKError {
            throw Self.map(error)
        }
    }
    
    func saveFoundReport(_ report: FoundReport) async throws -> FoundReport {
        let record = FoundReportMapper.toRecord(report: report)
        do {
            let savedRecord = try await database.save(record)
            print("✅ Saved FoundReport record: \(savedRecord.recordID.recordName), itemID: \(report.itemID.uuidString) — this is the write that must match a subscription's predicate exactly")
            let report = try FoundReportMapper.toFoundReport(record: savedRecord)
            return report
        } catch let error as CKError {
            print("❌ saveFoundReport failed for itemID \(report.itemID.uuidString): \(error)")
            throw Self.map(error)
        }
    }

    func fetchFoundReports(forItemIDs itemIDs: [UUID]) async throws -> [FoundReport] {
        guard !itemIDs.isEmpty else { return [] }

        let predicate = NSPredicate(format: "%K IN %@", RecordSchema.FoundReport.Field.itemID, itemIDs.map(\.uuidString))
        let query = CKQuery(recordType: RecordSchema.FoundReport.recordType, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: RecordSchema.FoundReport.Field.reportedAt, ascending: false)]

        do {
            var reports: [FoundReport] = []
            var cursor: CKQueryOperation.Cursor?
            repeat {
                let matchResults: [(CKRecord.ID, Result<CKRecord, Error>)]
                let nextCursor: CKQueryOperation.Cursor?
                if let cursor {
                    (matchResults, nextCursor) = try await database.records(continuingMatchFrom: cursor)
                }
                else {
                    (matchResults, nextCursor) = try await database.records(matching: query)
                }

                for (_, result) in matchResults {
                    if case .success(let record) = result {
                        reports.append(try FoundReportMapper.toFoundReport(record: record))
                    }
                }
                cursor = nextCursor
            } while cursor != nil

            return reports
        } catch let error as CKError {
            throw Self.map(error)
        }
    }

    func updateFoundReport(_ report: FoundReport) async throws -> FoundReport {
        do {
            let recordID = CKRecord.ID(recordName: report.id.uuidString)
            let existingRecord = try await database.record(for: recordID)
            let updatedRecord = FoundReportMapper.toRecord(report: report, existingRecord: existingRecord)
            let savedRecord = try await database.save(updatedRecord)
            return try FoundReportMapper.toFoundReport(record: savedRecord)
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
