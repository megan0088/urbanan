//
//  UniversalLinkParser.swift
//  urbanan
//
//  Created by Xaviero Yamin Loganta on 06/07/26.
//

import Foundation


enum UniversalLinkParser {
    static func itemID(from url: URL,
                       expectedHost: String = AppConfiguration.universalLinkHost.host() ?? "") -> UUID? {
        guard url.host()?.lowercased() ?? "" == expectedHost.lowercased() else { return nil }
        let components = url.pathComponents.filter { $0 != "/" }
        guard components.count == 2, components[0] == "item" else { return nil }
        return UUID(uuidString: components[1])
    }
}
