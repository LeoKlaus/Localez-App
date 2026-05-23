//
//  LanguageStats+mock.swift
//  Localez
//
//  Created by Leo Wehrfritz on 19.05.26.
//

import Localez_API

nonisolated extension LanguageStats {
    static let mockTranslated = LanguageStats(
        language: "en",
        translated: 42,
        needsReview: 0,
        missing: 0
    )
    
    static let mockInProgress = LanguageStats(
        language: "de",
        translated: 12,
        needsReview: 22,
        missing: 8
    )
    
    static let mockEmpty = LanguageStats(
        language: "fr",
        translated: 0,
        needsReview: 0,
        missing: 42
    )
}
