//
//  MockPhotoLibrarySaving.swift
//  TaggoTests
//

import Foundation

final class MockPhotoLibrarySaving: PhotoLibrarySaving, @unchecked Sendable {
    var saveImageResult = true
    private(set) var saveImageCallCount = 0
    private(set) var lastSavedImageData: Data?

    func saveImage(_ imageData: Data) async -> Bool {
        saveImageCallCount += 1
        lastSavedImageData = imageData
        return saveImageResult
    }
}
