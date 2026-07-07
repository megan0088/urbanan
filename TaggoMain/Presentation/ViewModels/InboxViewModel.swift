//
//  InboxViewModel.swift
//  TaggoMain
//

import Foundation
import Observation

@Observable
final class InboxViewModel {
    enum State: Equatable {
        case loading
        case loaded([FoundReport])
        case failure(message: String)
    }

    private(set) var state: State = .loading

    private let fetchInboxUseCase: FetchInboxUseCase
    private let markReportClaimedUseCase: MarkReportClaimedUseCase
    private let foundReportEvents: AsyncStream<Void>

    init(
        fetchInboxUseCase: FetchInboxUseCase,
        markReportClaimedUseCase: MarkReportClaimedUseCase,
        foundReportEvents: AsyncStream<Void>
    ) {
        self.fetchInboxUseCase = fetchInboxUseCase
        self.markReportClaimedUseCase = markReportClaimedUseCase
        self.foundReportEvents = foundReportEvents
    }

    func load() async {
        state = .loading
        do {
            let reports = try await fetchInboxUseCase.execute()
            state = .loaded(reports)
        } catch let error as TaggoError {
            state = .failure(message: userMessage(for: error))
        } catch {
            state = .failure(message: "Something went wrong. Please try again.")
        }
    }

    /// Reloads the Inbox every time a found-report push comes in — call once from
    /// the View via `.task`, alongside the initial `load()`.
    func observeFoundReportEvents() async {
        for await _ in foundReportEvents {
            await load()
        }
    }

    func markClaimed(_ report: FoundReport) async {
        guard case .loaded(var reports) = state else { return }
        do {
            let updated = try await markReportClaimedUseCase.execute(report)
            if let index = reports.firstIndex(where: { $0.id == updated.id }) {
                reports[index] = updated
            }
            state = .loaded(reports)
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
            return "That report couldn't be found."
        case .unauthorized:
            return "iCloud permission is required."
        case .quotaExceeded:
            return "iCloud storage is full."
        case .notOwner:
            return "Something went wrong. Please try again."
        case .missingField, .invalidFieldValue, .invalidRecordType:
            return "Something about that report wasn't valid."
        case .invalidLink:
            return "Something went wrong. Please try again."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
