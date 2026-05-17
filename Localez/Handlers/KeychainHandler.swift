//
//  KeychainHandler.swift
//  Localez
//
//  Created by Leo Wehrfritz on 17.05.26.
//

import SwiftUI
import os

enum KeychainError: LocalizedError {
    case unknown(id: Int32)
    
    public var errorDescription: String? {
        switch self {
        case .unknown(let id):
            String(localized: "Unknown keychain error code: \(id)")
        }
    }
}

final class KeychainHandler {

    private let accessGroup = "28KGVFV686.me.wehrfritz.Localez"
    
    static let standard = KeychainHandler()
    private init() {}

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: KeychainHandler.self)
    )
    
    func save(_ data: Data, service: String, account: String) throws {

        // Create query
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecAttrAccessGroup: accessGroup,
        ] as [CFString : Any] as CFDictionary

        // Add data in query to keychain
        let status = SecItemAdd(query, nil)

        if status == errSecDuplicateItem {
            // Item already exist, update it.
            let query = [
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecClass: kSecClassGenericPassword,
            ] as [CFString : Any] as CFDictionary

            let attributesToUpdate = [kSecValueData: data] as CFDictionary

            // Update existing item
            SecItemUpdate(query, attributesToUpdate)
        }

        else if status != errSecSuccess {
            KeychainHandler.logger.error("Keychainhandler: Error: \(status)")
            
            switch status {
            default:
                throw KeychainError.unknown(id: status)
            }
        }
    }

    func read(service: String, account: String) -> Data? {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecAttrAccessGroup: accessGroup,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as [CFString : Any] as CFDictionary

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)

        if status == errSecItemNotFound {
            KeychainHandler.logger.info("Keychain item for service \(service) and account \(account) not found")
            return nil
        }

        else if status != errSecSuccess {
            KeychainHandler.logger.error("Keychainhandler: Error: \(status)")
            return nil
        }

        return (result as? Data)
    }

    func delete(service: String, account: String) {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecAttrAccessGroup: accessGroup,
            kSecClass: kSecClassGenericPassword,
        ] as [CFString : Any] as CFDictionary

        // Delete item from keychain
        SecItemDelete(query)
    }
}
