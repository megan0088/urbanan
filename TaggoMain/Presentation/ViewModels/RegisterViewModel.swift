//
//  RegisterViewModel.swift
//  TaggoMain
//

import Foundation

@Observable
final class RegisterViewModel {
 
    enum State: Equatable {
        case idle
        case loading
        case success(qrCodeImageData: Data, itemLink: URL)
        case failure(message: String)
    }
 
    var name = ""
    var category = ""
    var color = ""
    var description = ""
    var selectedImageData: Data?
    private(set) var state: State = .idle
    private(set) var qrSaveError = false
    private(set) var qrSaved = false

    private let registerItemUseCase: RegisterItemUseCase
    private let photoLibrarySaving: PhotoLibrarySaving

    init(registerItemUseCase: RegisterItemUseCase, photoLibrarySaving: PhotoLibrarySaving) {
        self.registerItemUseCase = registerItemUseCase
        self.photoLibrarySaving = photoLibrarySaving
    }

    var isNameValid: Bool {
        !name.trimmed.isEmpty
    }

    func saveQRCodeToPhotos() async {
        guard case .success(let qrCodeImageData, _) = state else { return }
        if await photoLibrarySaving.saveImage(qrCodeImageData) {
            qrSaved = true
            try? await Task.sleep(for: .seconds(2))
            qrSaved = false
        } else {
            qrSaveError = true
        }
    }

    func dismissQRSaveError() {
        qrSaveError = false
    }

    func submit() async {
        guard isNameValid else { return }
        state = .loading
        let input = RegisterItemUseCase.Input(
            name: name.trimmed,
            category: category.trimmed,
            color: color.trimmed,
            description: description.trimmed,
            imageData: selectedImageData
        )
        do {
            let output = try await registerItemUseCase.execute(input)
            state = .success(qrCodeImageData: output.qrCodeImageData, itemLink: output.itemLink)
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
