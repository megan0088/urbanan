//
//  TaggoError.swift
//  SharedCore
//

import Foundation

enum TaggoError: Error, Equatable {
    case networkUnavailable
    case notFound
    case unauthorized
    case quotaExceeded
    case notOwner
    
    case missingField(String)
    case invalidFieldValue(String)
    case invalidRecordType(expected: String, actual: String)
    case invalidLink(_ link: String);
    
    case unknown(String)
}
