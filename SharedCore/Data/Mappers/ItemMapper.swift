//
//  ItemMapper.swift
//  SharedCore
//

import Foundation
import CloudKit

/// Pure `CKRecord` ↔ `Item` conversion — the only place `Item` is allowed
/// to touch a CloudKit type.
enum ItemMapper {
    static func toItem(record: CKRecord) throws -> Item {
        guard record.recordType == RecordSchema.Item.recordType else {
            throw TaggoError.invalidRecordType(expected: RecordSchema.Item.recordType, actual: record.recordType)
        }
        guard let id = UUID(uuidString: record.recordID.recordName) else {
            throw TaggoError.invalidFieldValue("recordID")
        }
        guard let ownerIDString = record[RecordSchema.Item.Field.ownerID] as? String,
              let ownerID = UUID(uuidString: ownerIDString) else {
            throw TaggoError.missingField(RecordSchema.Item.Field.ownerID)
        }
        guard let name = record[RecordSchema.Item.Field.name] as? String else {
            throw TaggoError.missingField(RecordSchema.Item.Field.name)
        }
        guard let category = record[RecordSchema.Item.Field.category] as? String else {
            throw TaggoError.missingField(RecordSchema.Item.Field.category)
        }
        guard let color = record[RecordSchema.Item.Field.color] as? String else {
            throw TaggoError.missingField(RecordSchema.Item.Field.color)
        }
//        guard let brand = record[RecordSchema.Item.Field.brand] as? String else {
//            throw TaggoError.missingField(RecordSchema.Item.Field.brand)
//        }
//        guard let statusRaw = record[RecordSchema.Item.Field.status] as? String,
//              let status = ItemStatus(rawValue: statusRaw) else {
//            throw TaggoError.missingField(RecordSchema.Item.Field.status)
//        }
        guard let createdAt = record[RecordSchema.Item.Field.createdAt] as? Date else {
            throw TaggoError.missingField(RecordSchema.Item.Field.createdAt)
        }
        guard let updatedAt = record[RecordSchema.Item.Field.updatedAt] as? Date else {
            throw TaggoError.missingField(RecordSchema.Item.Field.updatedAt)
        }

        let description = record[RecordSchema.Item.Field.description] as? String

        var imageData: Data?
        if let asset = record[RecordSchema.Item.Field.imageAsset] as? CKAsset, let fileURL = asset.fileURL {
            imageData = try? Data(contentsOf: fileURL)
        }

        return Item(
            id: id,
            ownerID: ownerID,
            name: name,
            category: category,
            color: color,
//            brand: brand,
            description: description,
            imageData: imageData,
//            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    static func toRecord(item: Item, existingRecord: CKRecord? = nil) -> CKRecord {
        let record = existingRecord ?? CKRecord(
            recordType: RecordSchema.Item.recordType,
            recordID: CKRecord.ID(recordName: item.id.uuidString)
        )

        record[RecordSchema.Item.Field.ownerID] = item.ownerID.uuidString
        record[RecordSchema.Item.Field.name] = item.name
        record[RecordSchema.Item.Field.category] = item.category
        record[RecordSchema.Item.Field.color] = item.color
//        record[RecordSchema.Item.Field.brand] = item.brand
        record[RecordSchema.Item.Field.description] = item.description
//        record[RecordSchema.Item.Field.status] = item.status.rawValue
        record[RecordSchema.Item.Field.createdAt] = item.createdAt
        record[RecordSchema.Item.Field.updatedAt] = item.updatedAt
        if let imageData = item.imageData, let asset = try? Self.makeAsset(from: imageData) {
            record[RecordSchema.Item.Field.imageAsset] = asset
        }

        return record
    }

    /// `CKAsset` requires a file on disk — writes the data to a temp file so it can be attached.
    private static func makeAsset(from data: Data) throws -> CKAsset {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try data.write(to: url)
        return CKAsset(fileURL: url)
    }
}
