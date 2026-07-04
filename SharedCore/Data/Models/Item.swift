//
//  Item.swift
//  SharedCore
//

import Foundation

/// Pure domain model — no CloudKit types leak in here.
/// `ItemMapper` is the only place that converts to/from `CKRecord`.
struct Item: Identifiable, Equatable {
    let id: UUID
    let ownerID: UUID
    var name: String
    var category: String
    var color: String
    var brand: String
    var description: String?
    var imageData: Data?
    var status: ItemStatus
    let createdAt: Date
    var updatedAt: Date
}
