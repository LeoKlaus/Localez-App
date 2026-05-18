//
//  MeResponse+mock.swift
//  Localez
//
//  Created by Leo Wehrfritz on 18.05.26.
//

import Foundation
import Localez_API

nonisolated extension MeResponse {
    static let mockAdmin = MeResponse(
        id: UUID(),
        username: "leo",
        globalRole: .admin,
        isActive: true,
        createdAt: Date(timeIntervalSinceNow: -60000),
        totpEnabled: true,
        passkeysConfigured: true
    )
    
    static let mock2fa = MeResponse(
        id: UUID(),
        username: "leo",
        globalRole: .admin,
        isActive: true,
        createdAt: Date(timeIntervalSinceNow: -60000),
        totpEnabled: true,
        passkeysConfigured: false
    )
    
    static let mockPasskey = MeResponse(
        id: UUID(),
        username: "leo",
        globalRole: .admin,
        isActive: true,
        createdAt: Date(timeIntervalSinceNow: -60000),
        totpEnabled: false,
        passkeysConfigured: true
    )
    
    static let mockInsecure = MeResponse(
        id: UUID(),
        username: "leo",
        globalRole: .admin,
        isActive: true,
        createdAt: Date(timeIntervalSinceNow: -60000),
        totpEnabled: false,
        passkeysConfigured: false
    )
}
