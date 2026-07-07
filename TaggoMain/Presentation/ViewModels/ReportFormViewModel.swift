//
//  ReportFormViewModel.swift
//  TaggoMain
//
//  Created by Xaviero Yamin Loganta on 06/07/26.
//

import Foundation


@Observable
final class ReportFormViewModel {
    enum State: Equatable {
        case idle
        case submitting
        case success
        case failure(message: String)
    }
    
    let itemID: UUID
    var station = ""
    var note = ""
    var selectedPhotoData: Data?
    
    private(set) var state: State = .idle
    private let reportFoundItemUseCase: ReportFoundItemUseCase
    init(itemID: UUID, reportFoundItemUseCase: ReportFoundItemUseCase) {
        self.itemID = itemID
        self.reportFoundItemUseCase = reportFoundItemUseCase
    }
    
    func submit() async {
        state = .submitting
        let input = ReportFoundItemUseCase.Input(itemID: itemID, station: station, note: note, photoData: selectedPhotoData)
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
            return "That item couldn't be found."
        case .unauthorized:
            return "iCloud permission is required."
        case .quotaExceeded:
            return "iCloud storage is full."
        case .missingField, .invalidFieldValue, .invalidRecordType:
            return "Something about that report wasn't valid."
        case .invalidLink:
            return "Something went wrong. Please try again."
        case .unknown, .notOwner:
            return "Something went wrong. Please try again."
        }
    }
}
