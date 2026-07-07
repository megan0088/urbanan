//
//  EditItemUseCase.swift
//  SharedCore
//

import Foundation

struct EditItemUseCase {
    private let cloudKitManager: CloudKitManaging
    private let currentUserProvider: CurrentUserProviding
    private let imageCompressor: ImageCompressing

    init(
        cloudKitManager: CloudKitManaging,
        currentUserProvider: CurrentUserProviding,
        imageCompressor: ImageCompressing
    ) {
        self.cloudKitManager = cloudKitManager
        self.currentUserProvider = currentUserProvider
        self.imageCompressor = imageCompressor
    }

    struct Input {
        var itemID: UUID
        var name: String
        var category: String
        var color: String
        var description: String
        var imageData: Data?
    }

    func execute(_ input: Input) async throws -> Item {
        let existing = try await cloudKitManager.fetchItem(id: input.itemID)

        guard existing.ownerID == currentUserProvider.currentUserID else {
            throw TaggoError.notOwner
        }

        let compressedImageData = try input.imageData.map {
            try imageCompressor.compress($0, maxDimensionPixels: 1200, jpegQUality: 0.7)
        }

        let updated = Item(
            id: existing.id,
            ownerID: existing.ownerID,
            name: input.name,
            category: input.category,
            color: input.color,
            description: input.description.isEmpty ? nil : input.description,
            imageData: compressedImageData ?? existing.imageData,
            createdAt: existing.createdAt,
            updatedAt: Date()
        )

        return try await cloudKitManager.updateItem(updated)
    }
}
