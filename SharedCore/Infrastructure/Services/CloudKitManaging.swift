//
//  CloudKitManaging.swift
//  SharedCore
//

import Foundation
import CloudKit

protocol CloudKitManaging: Sendable {
    func saveItem(_ item: Item) async throws -> Item
    func fetchItem(id: UUID) async throws -> Item
    func fetchItems(ownedBy ownerID: UUID) async throws -> [Item]
    func updateItem(_ item: Item) async throws -> Item
    func deleteItem(id: UUID) async throws
    func saveFoundReport(_ report: FoundReport) async throws -> FoundReport
    func fetchFoundReports(forItemIDs itemIDs: [UUID]) async throws -> [FoundReport]
    func updateFoundReport(_ report: FoundReport) async throws -> FoundReport
}
