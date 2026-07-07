//
//  ClipInvocationBridge.swift
//  TaggoClip
//
//  Created by Xaviero Yamin Loganta on 07/07/26.
//

import Foundation

@MainActor
final class ClipInvocationBridge {
    static let shared = ClipInvocationBridge()
    private init() {}
 
    private(set) var lastURL: URL?
 
    var onURLReceived: ((URL) -> Void)? {
        didSet {
            if let lastURL, let onURLReceived {
                onURLReceived(lastURL)
            }
        }
    }
 
    func receive(_ url: URL) {
        lastURL = url
        onURLReceived?(url)
    }
}
