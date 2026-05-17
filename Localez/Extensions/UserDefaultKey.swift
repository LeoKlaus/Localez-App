//
//  UserDefaultKey.swift
//  Localez
//
//  Created by Leo Wehrfritz on 17.05.26.
//


import Foundation

enum UserDefaultKey: String, CaseIterable {
    case activeInstanceId
    case connectedInstances
}

extension String {
    static func userDefaults(_ key: UserDefaultKey) -> String {
        key.rawValue
    }
}

extension UserDefaults {
    static let localez = UserDefaults(suiteName: "group.me.wehrfritz.localez")
}
