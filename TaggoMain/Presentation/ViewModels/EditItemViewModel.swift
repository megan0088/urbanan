//
//  EditItemViewModel.swift
//  TaggoMain
//
//  Created by Xaviero Yamin Loganta on 06/07/26.
//

import Foundation

@Observable
final class EditItemViewModel {

    enum State: Equatable {
        case idle
        case saving
        case failure(message: String)
    }

    var name: String
    var category: String
    var color: String
    var description: String
    var selectedImageData: Data?
    private(set) var state: State = .idle

    private let itemID: UUID
    private let editItemUseCase: EditItemUseCase

    init(item: Item, editItemUseCase: EditItemUseCase) {
        self.itemID = item.id
        self.name = item.name
        self.category = item.category
        self.color = item.color
        self.description = item.description ?? ""
        self.selectedImageData = item.imageData
        self.editItemUseCase = editItemUseCase
    }

    var isNameValid: Bool {
        !name.trimmed.isEmpty
    }

    func save() async -> Item? {
        guard isNameValid else { return nil }
        state = .saving
        let input = EditItemUseCase.Input(
            itemID: itemID,
            name: name.trimmed,
            category: category.trimmed,
            color: color.trimmed,
            description: description.trimmed,
            imageData: selectedImageData
        )
        do {
            let updated = try await editItemUseCase.execute(input)
            state = .idle
            return updated
        } catch let error as TaggoError {
            state = .failure(message: userMessage(for: error))
            return nil
        } catch {
            state = .failure(message: "Something went wrong. Please try again.")
            return nil
        }
    }

    private func userMessage(for error: TaggoError) -> String {
        switch error {
        case .networkUnavailable:
            return "You're offline — check your connection and try again."
        case .notFound:
            return "This item no longer exists."
        case .unauthorized:
            return "iCloud permission is required."
        case .quotaExceeded:
            return "iCloud storage is full."
        case .notOwner:
            return "You can only edit items you registered."
        case .missingField, .invalidFieldValue, .invalidRecordType:
            return "Something about this item's data wasn't valid."
        case .invalidLink:
            return "Something went wrong. Please try again."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
