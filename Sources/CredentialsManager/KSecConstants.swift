//
//  File.swift
//  
//
//  Created by David Stephens on 23/10/2020.
//

import Foundation

typealias KSecConstant = String

extension KSecConstant {
    static let secClass: KSecConstant = kSecClass as KSecConstant
    
    static let attrServer: KSecConstant = kSecAttrServer as KSecConstant
    static let attrAccount: KSecConstant = kSecAttrAccount as KSecConstant
    static let returnAttributes: KSecConstant = kSecReturnAttributes as KSecConstant
    static let returnData: KSecConstant = kSecReturnData as KSecConstant
}
