//
//  TaggoError.swift
//  SharedCore
//

import Foundation

enum TaggoError: Error, Equatable {
    case missingField(String)
    case invalidFieldValue(String)
    case invalidRecordType(expected: String, actual: String)
    case notFound
    case unauthorized
    case unknown(String)
}
