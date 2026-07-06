//
//  CloudKitManagerTests.swift
//  TaggoTests
//

import XCTest

// CloudKitManager wraps CKDatabase directly (a concrete CloudKit type, not a
// protocol), so its behavior can't be exercised without a live CloudKit
// connection. Its error-mapping and query logic are covered indirectly
// through the UseCase tests, which depend on CloudKitManaging via
// MockCloudKitManager instead.
final class CloudKitManagerTests: XCTestCase {
}
