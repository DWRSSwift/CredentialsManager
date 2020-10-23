//
//  File.swift
//  
//
//  Created by David Stephens on 23/10/2020.
//

import Foundation

extension CredentialsManager {
    public func addCredential(for server: String, username: String, secret: String) throws {
        try Self.addCredential(for: server, username: username, secret: secret, synchronise: self.syncEnabled)
    }
    
    public func addToken(for key: String, secret: String) throws {
        try Self.addToken(for: key, secret: secret, synchronise: self.syncEnabled)
    }
    
    public func findCredential(for server: String) throws -> Credentials {
        return try Self.findCredential(for: server)
    }
    
    public func findToken(for key: String) throws -> String {
        return  try Self.findToken(for: key)
    }
    
    public func updateCredential(for server: String, username: String, secret: String) throws {
        try Self.updateCredential(for: server, username: username, secret: secret)
    }
    
    public func updateCredential(for key: String, secret: String) throws {
        try Self.updateCredential(for: key, secret: secret)
    }

    public func deleteCredential(for server: String) throws {
        try Self.deleteCredential(for: server)
    }
    
    public func deleteToken(for key: String) throws {
        try Self.deleteToken(for: key)
    }
    
    public func upsertCredential(for server: String, username: String, secret: String) throws -> UpsertResult {
        try Self.upsertCredential(for: server, username: username, secret: secret)
    }
    
    public func upsertToken(for key: String, secret: String) throws -> UpsertResult {
        try Self.upsertToken(for: key, secret: secret)
    }
}
