//
//  ImageCompressor.swift
//  TaggoMain
//
//  Created by Xaviero Yamin Loganta on 05/07/26.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

final class ImageCompressor: ImageCompressing {
    func compress(_ data: Data, maxDimensionPixels: CGFloat, jpegQUality: CGFloat) throws -> Data {
        #if canImport(UIKit)
        guard let image = UIImage(data: data) else {
            throw TaggoError.invalidFieldValue("imageData")
        }
        
        let scale = min(1, maxDimensionPixels / max(image.size.width, image.size.height))
        let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        guard let jpegData = resized.jpegData(compressionQuality: jpegQUality) else {
            throw TaggoError.unknown("Could not encode compressed image")
        }
        
        return jpegData;
        #else
        throw TaggoError.unknown("Image Compression Requires UIKit")
        #endif
    }
}
