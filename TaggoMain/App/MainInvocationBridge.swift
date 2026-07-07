//
//  MainInvocationBridge.swift
//  TaggoMain
//

import Foundation

@MainActor
final class MainInvocationBridge {
    static let shared = MainInvocationBridge()
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
        print("🔗 MainInvocationBridge.receive: \(url.absoluteString), subscriber attached: \(onURLReceived != nil)")
        lastURL = url
        onURLReceived?(url)
    }
}
