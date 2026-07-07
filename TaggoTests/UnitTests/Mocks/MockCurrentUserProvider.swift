//
//  MockCurrentUserProvider.swift
//  TaggoTests
//

import Foundation

final class MockCurrentUserProvider: CurrentUserProviding, @unchecked Sendable {
    var currentUserID: UUID

    init(currentUserID: UUID = UUID()) {
        self.currentUserID = currentUserID
    }
}
