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
}
