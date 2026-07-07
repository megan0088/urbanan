//
//  QRManaging.swift
//  SharedCore
//

import Foundation

protocol QRManaging: Sendable {
    func generateQRCode(for itemID: UUID) throws -> Data
    func link(for itemID: UUID) -> URL
}
