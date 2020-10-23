//
//  File.swift
//  
//
//  Created by David Stephens on 23/10/2020.
//

import Foundation

func add(_ credentials: Credentials, synchronise: Bool) throws {
    let secretData = credentials.secret.data(using: String.Encoding.utf8)!
    var query: [KSecConstant: Any] = [.secClass: kSecClassGenericPassword,
                                      .attrAccount: credentials.username,
                                      kSecValueData as String: secretData]
    if let credentials = credentials as? ServerCredentials {
        query.updateValue(credentials.server, forKey: kSecAttrServer as String)
        query.updateValue(kSecClassInternetPassword, forKey: kSecClass as String)
    }
    if synchronise {
        query.updateValue(true, forKey: kSecAttrSynchronizable as KSecConstant)
    } else if #available(iOS 13.0, *) {
        query.updateValue(true, forKey: kSecUseDataProtectionKeychain as KSecConstant)
    }
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
        throw KeychainError(from: status)
    }
}

func find(forServer server: String) throws -> Credentials {
    let query: [KSecConstant: Any] = [.secClass: kSecClassInternetPassword,
                                      .attrServer: server]
    
    let (existingItem, apiKeyString) = try find(query: query)
    
    guard let account = existingItem[.attrAccount] as? String
    else {
        throw KeychainError.unexpectedPasswordData
    }
    return GenericCredentials(username: account, secret: apiKeyString)
}

func find(forUsername username: String) throws -> String {
    let query: [KSecConstant: Any] = [.secClass: kSecClassGenericPassword,
                                      .attrAccount as String: username]
    
    return try find(query: query).1
}

private let searchAttributes: [String : Any] = [kSecMatchLimit as String: kSecMatchLimitOne,
                                                .returnAttributes: true,
                                                .returnData: true,
                                                kSecAttrSynchronizable as String: kSecAttrSynchronizableAny
]

private func find(query: [String : Any]) throws -> ([KSecConstant : Any], String) {
    let queryWithSearchAttributes = query.merging(searchAttributes) { (current, _) in current }
    
    var item: CFTypeRef?
    let status = SecItemCopyMatching(queryWithSearchAttributes as CFDictionary, &item)
    guard status == errSecSuccess else {
        throw KeychainError(from: status)
    }
    guard let existingItem = item as? [String : Any],
          let apiKeyData = existingItem[kSecValueData as String] as? Data,
          let apiKeyString = String(data: apiKeyData, encoding: String.Encoding.utf8) else {
        throw KeychainError.unexpectedPasswordData
    }
    return (existingItem, apiKeyString)
}

func update(forServer server: String, username: String, secret: String) throws {
    let query: [String: Any] = [.secClass: kSecClassInternetPassword,
                                .attrServer: server]
    
    let apiKeyData = secret.data(using: String.Encoding.utf8)!
    let attributes: [String: Any] = [kSecAttrAccount as String: username,
                                     kSecValueData as String: apiKeyData]
    
    try update(with: query, attributes: attributes)
}

func update(forUsername user: String, secret: String, server: String?) throws {
    let query: [String: Any] = [.secClass: kSecClassGenericPassword,
                                .attrAccount: user]
    
    let apiKeyData = secret.data(using: String.Encoding.utf8)!
    var attributes: [String: Any] = [kSecValueData as String: apiKeyData]
    if let server = server {
        attributes.updateValue(server, forKey: kSecAttrServer as String)
        attributes.updateValue(kSecClassInternetPassword, forKey: kSecClass as String)
    }
    
    try update(with: query, attributes: attributes)
}

private func update(with query: [String : Any], attributes: [String : Any]) throws {
    let queryWithExtras = query.merging([kSecAttrSynchronizable as String: kSecAttrSynchronizableAny], uniquingKeysWith: {(current, _) in current})
    let status = SecItemUpdate(queryWithExtras as CFDictionary, attributes as CFDictionary)
    guard status == errSecSuccess else { throw KeychainError(from: status) }
}

func delete(forServer server: String) throws {
    let query: [String: Any] = [.secClass: kSecClassInternetPassword,
                                .attrServer: server]
    try delete(with: query)
}

func delete(forUsername username: String) throws {
    let query: [String: Any] = [.secClass: kSecClassGenericPassword,
                                .attrAccount as String: username]
    try delete(with: query)
}

private func delete(with query: [String : Any]) throws {
    let queryWithExtras = query.merging([kSecAttrSynchronizable as String: kSecAttrSynchronizableAny], uniquingKeysWith: {(current, _) in current})
    let status = SecItemDelete(queryWithExtras as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError(from: status) }
}
