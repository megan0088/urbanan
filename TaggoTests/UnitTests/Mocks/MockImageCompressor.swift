//
//  MockImageCompressor.swift
//  TaggoTests
//

import Foundation

final class MockImageCompressor: ImageCompressing, @unchecked Sendable {
    var compressResult: Result<Data, Error>?
    private(set) var compressCallCount = 0
    private(set) var lastInputData: Data?

    func compress(_ data: Data, maxDimensionPixels: CGFloat, jpegQUality: CGFloat) throws -> Data {
        compressCallCount += 1
        lastInputData = data

        guard let compressResult else {
            return data
        }
        switch compressResult {
        case .success(let output):
            return output
        case .failure(let error):
            throw error
        }
    }
}
