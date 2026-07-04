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
    
    case missingField(String)
    case invalidFieldValue(String)
    case invalidRecordType(expected: String, actual: String)
    
    case unknown(String)
}
