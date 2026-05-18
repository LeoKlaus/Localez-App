//
//  PasskeyResponse+mock.swift
//  Localez
//
//  Created by Leo Wehrfritz on 18.05.26.
//

import Foundation
import Localez_API

nonisolated extension PasskeyResponse {
    static let mock = PasskeyResponse(
        id: UUID().uuidString,
        name: "iPhone",
        aaguid: UUID().uuidString
    )
}
