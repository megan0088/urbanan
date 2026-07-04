//
//  RegisterViewModel.swift
//  TaggoMain
//

import Foundation
import Observation

@Observable
final class RegisterViewModel {
    enum State: Equatable {
        case idle
        case loading
        case success(qrCodeImageData: Data)
        case failure(message: String)
    }
    
    var name = ""
    var category = ""
    var color = "";
    var description = ""
    private(set) var state: State = .idle
    
    private let registerItemUseCase: RegisterItemUseCase
    
    init(registerItemUseCase: RegisterItemUseCase) {
        self.registerItemUseCase = registerItemUseCase
    }
    
    func submit() async {
        state = .loading
        let input = RegisterItemUseCase.Input(name: name, category: category, color: color, description: description)
        do {
            let output = try await registerItemUseCase.execute(input)
            state = .success(qrCodeImageData: output.qrCodeImageData)
        } catch {
            state = .failure(message: error.localizedDescription)
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
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
