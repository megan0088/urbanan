//
//  ScanViewModel.swift
//  urbanan
//
//  Created by Xaviero Yamin Loganta on 06/07/26.
//

import Foundation

@Observable
final class ScanViewModel {

    enum State: Equatable {
        case scanning
        case loading
        case found(Item)
        case failure(message: String)
    }

    private(set) var state: State = .scanning
    private let resolveScannedItemUC: ResolveScannedItemUseCase
    let reportFoundItemUseCase: ReportFoundItemUseCase

    init(resolveScannedItemUC: ResolveScannedItemUseCase, reportFoundItemUseCase: ReportFoundItemUseCase) {
        self.resolveScannedItemUC = resolveScannedItemUC
        self.reportFoundItemUseCase = reportFoundItemUseCase
    }

    func handleScannedCode(_ code: String) async {
        guard state == .scanning else { return }
        state = .loading
        do {
            let item = try await resolveScannedItemUC.execute(scannedString: code)
            state = .found(item)
        } catch let error as TaggoError {
            state = .failure(message: userMessage(for: error))
        } catch {
            state = .failure(message: "Something went wrong. Please try again.")
        }
    }

    func cameraPermissionDenied() {
        state = .failure(
            message: "Camera access is required to scan QR codes. Enable it in Settings > Taggo > Camera."
        )
    }

    func reset() {
        state = .scanning
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
        case .invalidLink(let message):
            return "That doesn't look like a valid Taggo QR code. \(message)"
        case .missingField, .invalidFieldValue, .invalidRecordType:
            return "Something about that item's data wasn't valid."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
