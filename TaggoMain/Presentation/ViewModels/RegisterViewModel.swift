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
 
    private let registerItemUseCase: RegisterItemUseCase
 
    init(registerItemUseCase: RegisterItemUseCase) {
        self.registerItemUseCase = registerItemUseCase
    }
 
    func submit() async {
        state = .loading
        let input = RegisterItemUseCase.Input(
            name: name,
            category: category,
            color: color,
            description: description,
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
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
