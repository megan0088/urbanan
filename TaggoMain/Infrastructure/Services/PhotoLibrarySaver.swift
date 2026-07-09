//
//  PhotoLibrarySaver.swift
//  TaggoMain
//

import UIKit
import Photos

final class PhotoLibrarySaver: PhotoLibrarySaving, @unchecked Sendable {
    func saveImage(_ imageData: Data) async -> Bool {
        guard let image = UIImage(data: imageData) else { return false }
        let status = await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                continuation.resume(returning: status)
            }
        }
        guard status == .authorized || status == .limited else { return false }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        return true
    }
}
