//
//  File.swift
//  
//
//  Created by David Stephens on 23/10/2020.
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

struct ServerCredentials: Credentials {
    var username: String
    var server: String
    var secret: String
}
