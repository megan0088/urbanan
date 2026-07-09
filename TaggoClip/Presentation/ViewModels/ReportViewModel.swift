//
//  ReportViewModel.swift
//  TaggoClip
//

import Foundation

@Observable
@MainActor
final class ReportViewModel {

    enum State: Equatable {
        case resolving
        case found(Item)
        case submitting
        case success
        case failure(message: String)
    }

    private(set) var state: State = .resolving
    private var resolvedItem: Item?

    var station = ""
    var note = ""
    var selectedPhotoData: Data?

    private let resolveScannedItemUseCase: ResolveScannedItemUseCase
    private let reportFoundItemUseCase: ReportFoundItemUseCase

    init(
        resolveScannedItemUseCase: ResolveScannedItemUseCase,
        reportFoundItemUseCase: ReportFoundItemUseCase
    ) {
        self.resolveScannedItemUseCase = resolveScannedItemUseCase
        self.reportFoundItemUseCase = reportFoundItemUseCase
    }

    func handleInvocation(url: URL) async {
        state = .resolving
        do {
            let item = try await resolveScannedItemUseCase.execute(scannedString: url.absoluteString)
            resolvedItem = item
            state = .found(item)
        } catch let error as TaggoError {
            print(error.localizedDescription)
            state = .failure(message: userMessage(for: error))
        } catch let error {
            
            state = .failure(message: "Something went wrong. Please try again. \(error.localizedDescription)")
        }
    }

    var isStationValid: Bool {
        !station.trimmed.isEmpty
    }

    func submitReport() async {
        guard let resolvedItem, isStationValid else { return }
        state = .submitting
        let input = ReportFoundItemUseCase.Input(
            itemID: resolvedItem.id,
            station: station,
            note: note,
            photoData: selectedPhotoData
        )
        do {
            _ = try await reportFoundItemUseCase.execute(input)
            state = .success
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
            return "This QR code doesn't match any registered item."
        case .unauthorized:
            return "iCloud permission is required."
        case .quotaExceeded:
            return "iCloud storage is full."
        case .notOwner:
            return "Something went wrong. Please try again."
        case .missingField, .invalidFieldValue, .invalidRecordType:
            return "Something about that item's data wasn't valid."
        case .invalidLink:
            return "That doesn't look like a valid Taggo QR code."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
