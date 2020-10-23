//
//  File.swift
//  
//
//  Created by David Stephens on 23/10/2020.
//

import Foundation

public enum KeychainError: Error {
    case readOnly
    case authFailed
    case itemNotFound
    case duplicateItem
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
    
    init(from status: OSStatus) {
        switch status {
        case errSecReadOnly:
            self = KeychainError.readOnly
        case errSecAuthFailed:
            self = KeychainError.authFailed
        case errSecItemNotFound:
            self = .itemNotFound
        case errSecDuplicateItem:
            self = KeychainError.duplicateItem
        default:
            self = KeychainError.unhandledError(status: status)
        }
    }
}
