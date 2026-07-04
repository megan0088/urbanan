//
//  MockQRManager.swift
//  TaggoTests
//

import Foundation

final class MockQRManager: QRManaging, @unchecked Sendable {
    var generateQRCodeResult: Result<Data, Error> = .success(Data("fake-qr-bytes".utf8))
    private(set) var generateQRCodeCallCount = 0
    private(set) var lastRequestedItemID: UUID?
 
    func generateQRCode(for itemID: UUID) throws -> Data {
        generateQRCodeCallCount += 1
        lastRequestedItemID = itemID
        switch generateQRCodeResult {
        case .success(let data): return data
        case .failure(let error): throw error
        }
    }
}
