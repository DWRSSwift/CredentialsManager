//
//  CredentialsManager.swift
//  WatchTime
//
//  Created by David Stephens on 16/07/2020.
//

import Foundation

public struct CredentialsManager {
    var syncEnabled: Bool
    init(synchronisationEnabled: Bool = false) {
        self.syncEnabled = synchronisationEnabled
    }
    
    public static func addCredential(for server: String, username: String, secret: String, synchronise: Bool = false) throws {
        try add(ServerCredentials(username: username, server: server, secret: secret), synchronise: synchronise)
    }
    
    public static func addToken(for key: String, secret: String, synchronise: Bool = false) throws {
        try add(GenericCredentials(username: key, secret: secret), synchronise: synchronise)
    }
    
    public static func findCredential(for server: String) throws -> Credentials {
        return try find(forServer: server)
    }
    
    public static func findToken(for key: String) throws -> String {
        return try find(forUsername: key)
    }
    
    public static func updateCredential(for server: String, username: String, secret: String) throws {
        try update(forServer: server, username: username, secret: secret)
    }
    
    public static func updateCredential(for key: String, secret: String) throws {
        try update(forUsername: key, secret: secret, server: nil)
    }

    public static func deleteCredential(for server: String) throws {
        try self.deleteCredential(for: server)
    }
    
    public static func deleteToken(for key: String) throws {
        try self.deleteToken(for: key)
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
    
    @discardableResult
    public static func upsertToken(for key: String, secret: String) throws -> UpsertResult {
        do {
            try Self.addToken(for: key, secret: secret)
            return .added
        } catch KeychainError.duplicateItem {
            try Self.updateCredential(for: key, secret: secret)
            return .updated
        }
    }
}

public enum UpsertResult: Equatable {
    case added
    case updated
}
