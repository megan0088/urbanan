//
//  QRManaging.swift
//  SharedCore
//

import Foundation

protocol QRManaging: Sendable {
    func generateQRCode(for itemID: UUID) throws -> Data
}
