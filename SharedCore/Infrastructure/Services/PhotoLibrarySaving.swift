//
//  PhotoLibrarySaving.swift
//  SharedCore
//

import Foundation

protocol PhotoLibrarySaving: Sendable {
    /// Requests add-only Photos permission if needed, then saves the image.
    /// Returns `false` (rather than throwing) when permission is denied — that's
    /// an expected outcome the caller shows as a normal alert, not an error state.
    func saveImage(_ imageData: Data) async -> Bool
}
