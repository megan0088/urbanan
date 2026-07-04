//
//  CurrentUserProvider.swift
//  TaggoMain
//

import Foundation
import Security

final class CurrentUserProvider: CurrentUserProviding {
    private static let service = "com.urbananTaggo.app.currentUser"
    private static let account = "currentUserID"
    
    var currentUserID: UUID;
    
    init() {
        if let existing = Self.readFromKeychain()  {
            currentUserID = existing
        }
        else {
            let newID = UUID()
            Self.writeToKeychain(newID)
            currentUserID = newID
        }
    }
    
    private static func readFromKeychain() -> UUID? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let uuidString = String(data: data, encoding: .utf8),
              let uuid = UUID(uuidString: uuidString)
            else { return nil }
        return uuid
    }
    
    private static func writeToKeychain(_ id: UUID) {
        let data = Data(id.uuidString.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
        SecItemAdd(query as CFDictionary, nil)
    }
}
