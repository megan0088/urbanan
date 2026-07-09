//
//  ItemListViewModel.swift
//  TaggoMain

import Foundation

@Observable
final class ItemListViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded([Item])
        case failure(message: String)
    }
    
    private(set) var state: State = .idle
    var searchText = ""
    private let listItemsUseCase: ListItemsUseCase

    init(listItemsUseCase: ListItemsUseCase) {
        self.listItemsUseCase = listItemsUseCase
    }

    /// Flattened view of `state` — `[]` unless items have actually loaded, so
    /// callers don't need to pattern-match the state enum themselves.
    var items: [Item] {
        if case .loaded(let items) = state { return items }
        return []
    }

    var filteredItems: [Item] {
        guard !searchText.isEmpty else { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    func item(withID id: UUID) -> Item? {
        items.first { $0.id == id }
    }

    func load() async {
        state = .loading
        do  {
            let items = try await listItemsUseCase.execute()
            state = .loaded(items)
        } catch let error as TaggoError {
            state = .failure(message: userMessage(for: error))
        } catch {
            state = .failure(message: "Something went wrong. Please try again.")
        }
    }

    private func userMessage(for error: TaggoError) -> String {
        switch error {
        case .networkUnavailable:
            return "You're offline — check your connection and try again."
        case .notFound:
            return "That item couldn't be found."
        case .unauthorized:
            return "iCloud permission is required to register an item."
        case .quotaExceeded:
            return "iCloud storage is full."
        case .missingField, .invalidFieldValue, .invalidRecordType:
            return "Something about that item's data wasn't valid."
        case .invalidLink:
            return "Link is Invalid"
        case .unknown, .notOwner:
            return "Something went wrong. Please try again."
        }
    }
}
