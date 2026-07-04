//
//  ItemMapperTests.swift
//  TaggoTests
//

import XCTest
import CloudKit

final class ItemMapperTests: XCTestCase {
    private func makeRecord(
        id: UUID = UUID(),
        ownerID: UUID = UUID(),
        name: String = "Blue Backpack",
        category: String = "Bags",
        color: String = "Blue",
        brand: String = "Fjallraven",
        description: String? = "Well-worn daypack",
        status: ItemStatus = .active,
        createdAt: Date = Date(timeIntervalSince1970: 0),
        updatedAt: Date = Date(timeIntervalSince1970: 100)
    ) -> CKRecord {
        let record = CKRecord(recordType: RecordSchema.Item.recordType, recordID: CKRecord.ID(recordName: id.uuidString))
        record[RecordSchema.Item.Field.ownerID] = ownerID.uuidString
        record[RecordSchema.Item.Field.name] = name
        record[RecordSchema.Item.Field.category] = category
        record[RecordSchema.Item.Field.color] = color
        record[RecordSchema.Item.Field.brand] = brand
        record[RecordSchema.Item.Field.description] = description
        record[RecordSchema.Item.Field.status] = status.rawValue
        record[RecordSchema.Item.Field.createdAt] = createdAt
        record[RecordSchema.Item.Field.updatedAt] = updatedAt
        return record
    }

    func test_toItem_mapsAllFieldsFromRecord() throws {
        let id = UUID()
        let ownerID = UUID()
        let record = makeRecord(id: id, ownerID: ownerID)

        let item = try ItemMapper.toItem(record: record)

        XCTAssertEqual(item.id, id)
        XCTAssertEqual(item.ownerID, ownerID)
        XCTAssertEqual(item.name, "Blue Backpack")
        XCTAssertEqual(item.category, "Bags")
        XCTAssertEqual(item.color, "Blue")
        XCTAssertEqual(item.brand, "Fjallraven")
        XCTAssertEqual(item.description, "Well-worn daypack")
        XCTAssertEqual(item.status, .active)
        XCTAssertEqual(item.createdAt, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(item.updatedAt, Date(timeIntervalSince1970: 100))
        XCTAssertNil(item.imageData)
    }

    func test_toItem_throwsOnWrongRecordType() {
        let record = CKRecord(recordType: "SomethingElse", recordID: CKRecord.ID(recordName: UUID().uuidString))

        XCTAssertThrowsError(try ItemMapper.toItem(record: record)) { error in
            XCTAssertEqual(
                error as? TaggoError,
                .invalidRecordType(expected: RecordSchema.Item.recordType, actual: "SomethingElse")
            )
        }
    }

    func test_toItem_throwsOnMissingRequiredField() {
        let record = makeRecord()
        record[RecordSchema.Item.Field.name] = nil

        XCTAssertThrowsError(try ItemMapper.toItem(record: record)) { error in
            XCTAssertEqual(error as? TaggoError, .missingField(RecordSchema.Item.Field.name))
        }
    }

    func test_toItem_allowsNilOptionalDescription() throws {
        let record = makeRecord(description: nil)

        let item = try ItemMapper.toItem(record: record)

        XCTAssertNil(item.description)
    }

    func test_toRecord_mapsAllFieldsOntoNewRecord() {
        let item = Item(
            id: UUID(),
            ownerID: UUID(),
            name: "Red Umbrella",
            category: "Accessories",
            color: "Red",
            brand: "Generic",
            description: nil,
            imageData: nil,
            status: .archived,
            createdAt: Date(timeIntervalSince1970: 10),
            updatedAt: Date(timeIntervalSince1970: 20)
        )

        let record = ItemMapper.toRecord(item: item)

        XCTAssertEqual(record.recordType, RecordSchema.Item.recordType)
        XCTAssertEqual(record.recordID.recordName, item.id.uuidString)
        XCTAssertEqual(record[RecordSchema.Item.Field.ownerID] as? String, item.ownerID.uuidString)
        XCTAssertEqual(record[RecordSchema.Item.Field.name] as? String, "Red Umbrella")
        XCTAssertEqual(record[RecordSchema.Item.Field.status] as? String, ItemStatus.archived.rawValue)
    }

    func test_roundTrip_recordToItemToRecordPreservesCoreFields() throws {
        let original = makeRecord()

        let item = try ItemMapper.toItem(record: original)
        let roundTripped = ItemMapper.toRecord(item: item)

        XCTAssertEqual(roundTripped.recordID.recordName, original.recordID.recordName)
        XCTAssertEqual(roundTripped[RecordSchema.Item.Field.name] as? String, original[RecordSchema.Item.Field.name] as? String)
        XCTAssertEqual(roundTripped[RecordSchema.Item.Field.status] as? String, original[RecordSchema.Item.Field.status] as? String)
    }
}
