//
//  AppConfiguration.swift
//  SharedCore
//

import Foundation

enum AppConfiguration {
    static let cloudKitContainerIdentifier = "iCloud.com.eganugraha.Taggo.app"
    static let universalLinkHost = URL(string: "https://urbananTaggo.netlify.app")!
    static let universalLinkItemPath = "/item"

    /// PLACEHOLDER — points nowhere yet. This becomes real once the relay function that
    /// lets the App Clip submit reports over HTTP (working around CloudKit-Anonymous's
    /// read-only restriction) is built and deployed. HTTPFoundReportSubmitter is fully
    /// wired to use this the moment it resolves to a real endpoint.
    static let reportRelayURL = URL(string: "https://urbananTaggo.netlify.app/.netlify/functions/submit-report")!
}
