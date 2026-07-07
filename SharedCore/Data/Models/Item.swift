//
//  Item.swift
//  SharedCore
//

import Foundation

/// Pure domain model — no CloudKit types leak in here.
/// `ItemMapper` is the only place that converts to/from `CKRecord`.
struct Item: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let ownerID: UUID
    var name: String
    var category: String
    var color: String
    var description: String?
    var imageData: Data?
    let createdAt: Date
    var updatedAt: Date
}
