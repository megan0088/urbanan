//
//  ItemDetailViewModel.swift
//  TaggoMain
//
//  Created by Xaviero Yamin Loganta on 06/07/26.
//

import Foundation

@Observable
final class ItemDetailViewModel {

    enum State: Equatable {
        case idle
        case working
        case deleted
        case failure(message: String)
    }

    private(set) var item: Item
    private(set) var state: State = .idle

    let qrCodeImageData: Data?

    private let deleteItemUseCase: DeleteItemUseCase

    init(item: Item, deleteItemUseCase: DeleteItemUseCase, qrManager: QRManaging) {
        self.item = item
        self.deleteItemUseCase = deleteItemUseCase
        self.qrCodeImageData = try? qrManager.generateQRCode(for: item.id)
    }

    func delete() async {
        state = .working
        do {
            try await deleteItemUseCase.execute(itemID: item.id)
            state = .deleted
        } catch let error as TaggoError {
            state = .failure(message: userMessage(for: error))
        } catch {
            state = .failure(message: "Something went wrong. Please try again.")
        }
    }

    /// Called after a successful edit — updates the displayed item in place without
    /// needing to refetch, since EditItemUseCase already returns the saved result.
    func applyEdit(_ updated: Item) {
        item = updated
        state = .idle
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
            return "You can only delete items you registered."
        case .missingField, .invalidFieldValue, .invalidRecordType:
            return "Something about this item's data wasn't valid."
        case .invalidLink:
            return "Something went wrong. Please try again."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
