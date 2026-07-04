//
//  QRManager.swift
//  SharedCore
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
#if canImport(UIKit)
import UIKit
#endif

final class QRManager: QRManaging {
    private let baseURL: URL
    
    init(baseURL: URL = AppConfiguration.universalLinkHost) {
        self.baseURL = baseURL
    }
    
    func generateQRCode(for itemID: UUID) throws -> Data {
        var components = URLComponents(url: baseURL.appendingPathComponent("item"), resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "id", value: itemID.uuidString)]
        guard let link = components?.url else {
            throw TaggoError.unknown("COuld not Build Universal Link for item \(itemID)")
        }
        
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(link.absoluteString.utf8)
        guard let outputImage = filter.outputImage else {
            throw TaggoError.unknown("Could not generate QR Code for item \(itemID)")
        }
        
        // hasil dari output image itu harusnya kecil bet
        let scaled = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else {
            throw TaggoError.unknown("Could not generate QR Code for item \(itemID)")
        }
        
        #if canImport(UIKit)
        guard let pngData = UIImage(cgImage: cgImage).pngData() else {
            throw TaggoError.unknown("Could not convert QR Code for item \(itemID) to PNG")
        }
        
        return pngData
        #else
        throw TaggoError.unknown("Not implemented on this platform")
        #endif
    }
}
