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

    struct ReportSection: Identifiable {
        let header: String
        let reports: [FoundReport]
        var id: String { header }
    }

    private(set) var state: State = .loading

    /// Flattened, real data only — `[]` unless reports have actually loaded.
    var reports: [FoundReport] {
        if case .loaded(let reports) = state { return reports }
        return []
    }

    var hasUnread: Bool {
        reports.contains { !$0.isRead }
    }

    /// Sorted newest-first by `FetchInboxUseCase` already.
    var pendingReports: [FoundReport] {
        reports.filter { $0.status == .pending }
    }

    /// What the Inbox screen should actually render — falls back to seeded
    /// preview data in DEBUG builds when there's nothing real to show (empty
    /// or failed), so the screen is never empty while demoing without live
    /// CloudKit data. Never used for `reports`/`pendingReports` above, which
    /// stay real-data-only since those drive the main page's unread badge/highlight.
    var displayReports: [FoundReport] {
        switch state {
        case .loaded(let reports):
            #if DEBUG
            return reports.isEmpty ? InboxSeeder.reports : reports
            #else
            return reports
            #endif
        case .failure:
            #if DEBUG
            return InboxSeeder.reports
            #else
            return []
            #endif
        case .loading:
            return []
        }
    }

    var groupedSections: [ReportSection] {
        let calendar = Calendar.current
        let now = Date()
        var today: [FoundReport] = []
        var thisWeek: [FoundReport] = []
        var lastWeek: [FoundReport] = []
        var older: [FoundReport] = []

        for report in displayReports {
            if calendar.isDateInToday(report.reportedAt) {
                today.append(report)
            } else if calendar.isDate(report.reportedAt, equalTo: now, toGranularity: .weekOfYear) {
                thisWeek.append(report)
            } else if let oneWeekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now),
                      calendar.isDate(report.reportedAt, equalTo: oneWeekAgo, toGranularity: .weekOfYear) {
                lastWeek.append(report)
            } else {
                older.append(report)
            }
        }

        var sections: [ReportSection] = []
        if !today.isEmpty    { sections.append(ReportSection(header: "Today", reports: today)) }
        if !thisWeek.isEmpty { sections.append(ReportSection(header: "This Week", reports: thisWeek)) }
        if !lastWeek.isEmpty { sections.append(ReportSection(header: "Last Week", reports: lastWeek)) }
        if !older.isEmpty    { sections.append(ReportSection(header: "Older", reports: older)) }
        return sections
    }

    func item(for report: FoundReport, in items: [Item]) -> Item? {
        if let found = items.first(where: { $0.id == report.itemID }) { return found }
        #if DEBUG
        return InboxSeeder.item(for: report)
        #else
        return nil
        #endif
    }

    private let fetchInboxUseCase: FetchInboxUseCase
    private let markReportClaimedUseCase: MarkReportClaimedUseCase
    private let markReportReadUseCase: MarkReportReadUseCase
    private let foundReportEvents: AsyncStream<Void>

    init(
        fetchInboxUseCase: FetchInboxUseCase,
        markReportClaimedUseCase: MarkReportClaimedUseCase,
        markReportReadUseCase: MarkReportReadUseCase,
        foundReportEvents: AsyncStream<Void>
    ) {
        self.fetchInboxUseCase = fetchInboxUseCase
        self.markReportClaimedUseCase = markReportClaimedUseCase
        self.markReportReadUseCase = markReportReadUseCase
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

    /// Best-effort — failing to flip the read flag shouldn't block or error out
    /// the user just for opening a report they already found in their inbox.
    func markAsRead(_ report: FoundReport) async {
        guard case .loaded(var reports) = state, !report.isRead else { return }
        guard let updated = try? await markReportReadUseCase.execute(report) else { return }
        if let index = reports.firstIndex(where: { $0.id == updated.id }) {
            reports[index] = updated
            state = .loaded(reports)
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

// MARK: - Debug Seeder

#if DEBUG
private enum InboxSeeder {
    private static let id1 = UUID()
    private static let id2 = UUID()
    private static let id3 = UUID()
    private static let id4 = UUID()

    static let reports: [FoundReport] = [
        FoundReport(
            id: UUID(), itemID: id1,
            station: "Stasiun Gambir",
            note: "Saya menemukan tas ini di rak bagasi atas, sudah saya serahkan ke petugas.",
            photoData: nil, status: .pending, isRead: false,
            reportedAt: Date().addingTimeInterval(-300),
            claimedAt: nil
        ),
        FoundReport(
            id: UUID(), itemID: id2,
            station: "Stasiun Sudirman",
            note: nil,
            photoData: nil, status: .pending, isRead: false,
            reportedAt: Date().addingTimeInterval(-3600),
            claimedAt: nil
        ),
        FoundReport(
            id: UUID(), itemID: id3,
            station: "Stasiun Tanah Abang",
            note: "Ditemukan di bangku tunggu peron 2, kondisi masih baik.",
            photoData: nil, status: .pending, isRead: true,
            reportedAt: Date().addingTimeInterval(-86400),
            claimedAt: nil
        ),
        FoundReport(
            id: UUID(), itemID: id4,
            station: "Stasiun MRT Lebak Bulus",
            note: nil,
            photoData: nil, status: .claimed, isRead: true,
            reportedAt: Date().addingTimeInterval(-86400 * 8),
            claimedAt: Date().addingTimeInterval(-86400 * 7)
        ),
    ]

    static let items: [Item] = [
        Item(id: id1, ownerID: UUID(), name: "Tas Ransel Biru", category: "Bag",
             color: "Biru Navy", description: "Tas ransel biru navy dengan kompartemen laptop",
             imageData: nil, createdAt: Date(), updatedAt: Date()),
        Item(id: id2, ownerID: UUID(), name: "AirPods Pro", category: "Electronics",
             color: "Putih", description: nil,
             imageData: nil, createdAt: Date(), updatedAt: Date()),
        Item(id: id3, ownerID: UUID(), name: "Dompet Kulit Coklat", category: "Wallet",
             color: "Coklat", description: nil,
             imageData: nil, createdAt: Date(), updatedAt: Date()),
        Item(id: id4, ownerID: UUID(), name: "KTP / ID Card", category: "Document",
             color: "Biru", description: nil,
             imageData: nil, createdAt: Date(), updatedAt: Date()),
    ]

    static func item(for report: FoundReport) -> Item? {
        items.first { $0.id == report.itemID }
    }
}
#endif
