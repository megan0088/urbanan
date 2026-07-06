//
//  QRManagerTests.swift
//  TaggoTests
//

import XCTest

final class QRManagerTests: XCTestCase {
    private let baseURL = URL(string: "https://example.com")!

    func test_link_buildsItemPathWithItemID() {
        let sut = QRManager(baseURL: baseURL)
        let itemID = UUID()

        let link = sut.link(for: itemID)

        XCTAssertEqual(link, baseURL.appendingPathComponent("item").appendingPathComponent(itemID.uuidString))
    }

    func test_generateQRCode_producesNonEmptyPNGData() throws {
        let sut = QRManager(baseURL: baseURL)

        let data = try sut.generateQRCode(for: UUID())

        XCTAssertFalse(data.isEmpty)
        // PNG magic number check
        XCTAssertEqual(Array(data.prefix(8)), [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
    }

    func test_generateQRCode_differentItemIDsProduceDifferentData() throws {
        let sut = QRManager(baseURL: baseURL)

        let first = try sut.generateQRCode(for: UUID())
        let second = try sut.generateQRCode(for: UUID())

        XCTAssertNotEqual(first, second)
    }
}
