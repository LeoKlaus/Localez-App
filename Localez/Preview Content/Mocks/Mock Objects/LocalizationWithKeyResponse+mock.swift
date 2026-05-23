//
//  LocalizationWithKeyResponse+mock.swift
//  Localez
//
//  Created by Leo Wehrfritz on 19.05.26.
//

import Foundation
import Localez_API

nonisolated extension LocalizationWithKeyResponse {
    static let mock = LocalizationWithKeyResponse(
        id: UUID().uuidString,
        language: "de",
        variationType: ._none,
        variationKey: nil,
        state: .new,
        value: nil,
        valueSetBy: nil,
        updatedAt: .distantPast,
        stringKeyId: UUID().uuidString,
        key: "Print %@",
        comment: "This key includes a string",
        sourceValue: "Print %@",
        aiSuggestion: "%@ ausgeben"
    )
    
    static let mockNeedsReview = LocalizationWithKeyResponse(
        id: UUID().uuidString,
        language: "de",
        variationType: ._none,
        variationKey: nil,
        state: .needsReview,
        value: "%@ ausgeben",
        valueSetBy: UUID().uuidString,
        updatedAt: Date(timeIntervalSinceNow: -600),
        stringKeyId: UUID().uuidString,
        key: "Print %@",
        comment: "This key includes a string",
        sourceValue: "Print %@",
        aiSuggestion: "%@ ausgeben"
    )
    
    static let mockTranslated = LocalizationWithKeyResponse(
        id: UUID().uuidString,
        language: "de",
        variationType: ._none,
        variationKey: nil,
        state: .translated,
        value: "%@ ausgeben",
        valueSetBy: UUID().uuidString,
        updatedAt: Date(timeIntervalSinceNow: -600),
        stringKeyId: UUID().uuidString,
        key: "Print %@",
        comment: "This key includes a string",
        sourceValue: "Print %@",
        aiSuggestion: "%@ ausgeben"
    )
    
    static let mockDeviceVariation = LocalizationWithKeyResponse(
        id: UUID().uuidString,
        language: "de",
        variationType: .device,
        variationKey: .deviceiPhone,
        state: .needsReview,
        value: "Auf deinem iPhone speichern",
        valueSetBy: UUID().uuidString,
        updatedAt: Date(timeIntervalSinceNow: -600),
        stringKeyId: UUID().uuidString,
        key: "Save to your device",
        comment: "This key varies by device",
        sourceValue: "Save to your iPhone",
        aiSuggestion: "Auf Ihrem iPhone speichern"
    )
    
    static let mockPluralVariation = LocalizationWithKeyResponse(
        id: UUID().uuidString,
        language: "de",
        variationType: .plural,
        variationKey: .pluralOne,
        state: .needsReview,
        value: "Ein Dokument",
        valueSetBy: UUID().uuidString,
        updatedAt: Date(timeIntervalSinceNow: -600),
        stringKeyId: UUID().uuidString,
        key: "%lld documents",
        comment: "This key varies by plural",
        sourceValue: "One document",
        aiSuggestion: "Auf Ihrem iPhone speichern"
    )
}
