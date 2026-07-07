//
//  CurrentUserProviding.swift
//  TaggoMain

import Foundation

protocol CurrentUserProviding: Sendable {
    var currentUserID: UUID {get};
}
