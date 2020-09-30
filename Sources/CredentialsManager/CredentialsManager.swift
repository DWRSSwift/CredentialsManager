//
//  CredentialsManager.swift
//  WatchTime
//
//  Created by David Stephens on 16/07/2020.
//

import Foundation
public protocol Credentials {
    var username: String {get set}
    var secret: String {get set}
}

struct GenericCredentials: Credentials {
    var username: String
    var secret: String
}

public enum KeychainError: Error {
    case noPassword
    case duplicateItem
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

public struct CredentialsManager {
    public static func addCredential(for server: String, username: String, secret: String) throws {
        let secretData = secret.data(using: String.Encoding.utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: username,
                                    kSecAttrServer as String: server,
                                    kSecValueData as String: secretData]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status != errSecDuplicateItem else { throw KeychainError.duplicateItem }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }
    
    public static func findCredential(for server: String) throws -> Credentials {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: server,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
        
        guard let existingItem = item as? [String : Any],
            let apiKeyData = existingItem[kSecValueData as String] as? Data,
            let apiKeyString = String(data: apiKeyData, encoding: String.Encoding.utf8),
            let account = existingItem[kSecAttrAccount as String] as? String
            else {
                throw KeychainError.unexpectedPasswordData
        }
        return GenericCredentials(username: account, secret: apiKeyString)
    }
    
    public static func updateCredential(for server: String, username: String, secret: String) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: server]
        let apiKeyData = secret.data(using: String.Encoding.utf8)!
        let attributes: [String: Any] = [kSecAttrAccount as String: username,
                                         kSecValueData as String: apiKeyData]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }

    public static func deleteCredential(for server: String) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: server]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
    
    public static func upsertCredential(for server: String, username: String, secret: String) throws -> UpsertResult {
        do {
            try Self.addCredential(for: server, username: username, secret: secret)
            return .added
        } catch KeychainError.duplicateItem {
            try Self.updateCredential(for: server, username: username, secret: secret)
            return .updated
        }
    }


}

public enum UpsertResult: Equatable {
    case added
    case updated
}
