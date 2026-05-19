//
//  ProjectResponse+mock.swift
//  Localez
//
//  Created by Leo Wehrfritz on 18.05.26.
//

import Foundation
import Localez_API

nonisolated extension ProjectResponse {
    static let mock = ProjectResponse(
        id: UUID().uuidString,
        name: "Paperparrot",
        sourceLanguage: "en",
        createdBy: UserResponse.mockAdmin.id,
        createdAt: Date(timeIntervalSinceNow: -60000),
        hasIcon: true,
        languages: [
            "de",
            "fr",
            "en-GB"
        ]
    )
    
    static let mock2 = ProjectResponse(
        id: UUID().uuidString,
        name: "plappa",
        sourceLanguage: "en",
        createdBy: UserResponse.mockAdmin.id,
        createdAt: Date(timeIntervalSinceNow: -120000),
        hasIcon: true,
        languages: [
            "de",
            "fr",
            "en-GB",
            "zh-HANS"
        ]
    )
    
    static let mock3 = ProjectResponse(
        id: UUID().uuidString,
        name: "OpenAirScan",
        sourceLanguage: "en",
        createdBy: UserResponse.mockAdmin.id,
        createdAt: Date(timeIntervalSinceNow: -640000),
        hasIcon: false,
        languages: [
            "de"
        ]
    )
}
