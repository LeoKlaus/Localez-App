//
//  UserResponse+mock.swift
//  Localez
//
//  Created by Leo Wehrfritz on 18.05.26.
//

import Foundation
import Localez_API

nonisolated extension UserResponse {
    static let mockAdmin = UserResponse(
        id: UUID().uuidString,
        username: "leo",
        globalRole: .admin,
        isActive: true,
        createdAt: Date(timeIntervalSinceNow: -120000)
    )
    
    static let mockUser = UserResponse(
        id: UUID().uuidString,
        username: "demo",
        globalRole: .user,
        isActive: true,
        createdAt: Date(timeIntervalSinceNow: -60000)
    )
}
