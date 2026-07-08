//
//  AppConfiguration.swift
//  SharedCore
//

import Foundation

enum AppConfiguration {
    /// Read from Info.plist rather than hardcoded so it tracks whatever
    /// TAGGO_BUNDLE_ID_BASE the target was built with — the main app and the
    /// App Clip each embed their own value at build time, and a developer
    /// signing under their own team (see Config.xcconfig.example) gets their
    /// own container automatically instead of pointing at the shared one.
    static let cloudKitContainerIdentifier = Bundle.main.object(forInfoDictionaryKey: "TaggoCloudKitContainerIdentifier") as! String
    static let universalLinkHost = URL(string: "https://urbanantaggo.netlify.app")!
    static let universalLinkItemPath = "/item"

    /// PLACEHOLDER — points nowhere yet. This becomes real once the relay function that
    /// lets the App Clip submit reports over HTTP (working around CloudKit-Anonymous's
    /// read-only restriction) is built and deployed. HTTPFoundReportSubmitter is fully
    /// wired to use this the moment it resolves to a real endpoint.
    static let reportRelayURL = URL(string: "https://urbanantaggo.netlify.app/.netlify/functions/submit-report")!
}
