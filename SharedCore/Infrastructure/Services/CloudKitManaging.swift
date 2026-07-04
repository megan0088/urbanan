//
//  CloudKitManaging.swift
//  SharedCore
//

import Foundation
import CloudKit

protocol CloudKitManaging: Sendable {
    func saveItem(_ item: Item) async throws -> Item
}
