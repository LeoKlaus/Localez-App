//
//  ApiError+localizedError.swift
//  Localez
//
//  Created by Leo Wehrfritz on 17.05.26.
//

import Foundation
import Localez_API

extension ApiError: @retroactive LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            String(localized: "Invalid server response")
        case .notLoggedIn:
            String(localized: "Not logged in")
        case .badRequest(_):
            String(localized: "Bad request")
        case .unauthorized(_):
            String(localized: "Unauthorized")
        case .totpRequired:
            String(localized: "Two factor authentication required")
        case .forbidden:
            String(localized: "Forbidden")
        case .notFound:
            String(localized: "Not found")
        case .methodNotAllowed:
            String(localized: "Method not allowed")
        case .conflict(_):
            String(localized: "Conflict")
        case .validationError(_):
            String(localized: "Validation error")
        case .internalServerError(_):
            String(localized: "Internal server error")
        case .badGateway:
            String(localized: "Bad gateway")
        case .couldntGetHost:
            String(localized: "Couldn't get host")
        case .couldntGenerateChallengeData:
            String(localized: "Couldn't generate passkey challenge data")
        case .missingCredential:
            String(localized: "Couldn't get Passkey credential")
        case .missingAssertion:
            String(localized: "Couldn't get Passkey assertion")
        }
    }
}

extension ApiError: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidResponse:
            String(localized: "Invalid server response")
        case .notLoggedIn:
            String(localized: "Not logged in")
        case .badRequest(let response):
            if let response, let responseStr = String(data: response, encoding: .utf8) {
                String(localized: "Bad request. Response:\n\(responseStr)")
            } else {
                String(localized: "Bad request")
            }
        case .unauthorized(let response):
            if let response, let responseStr = String(data: response, encoding: .utf8) {
                String(localized: "Unauthorized. Response:\n\(responseStr)")
            } else {
                String(localized: "Unauthorized")
            }
        case .totpRequired:
            String(localized: "Two factor authentication required")
        case .forbidden:
            String(localized: "Forbidden")
        case .notFound:
            String(localized: "Not found")
        case .methodNotAllowed:
            String(localized: "Method not allowed")
        case .conflict(let response):
            if let response, let responseStr = String(data: response, encoding: .utf8) {
                String(localized: "Conflict. Response:\n\(responseStr)")
            } else {
                String(localized: "Conflict")
            }
        case .validationError(let response):
            if let response, let responseStr = String(data: response, encoding: .utf8) {
                String(localized: "Validation error. Response:\n\(responseStr)")
            } else {
                String(localized: "Validation error")
            }
        case .internalServerError(let response):
            if let response, let responseStr = String(data: response, encoding: .utf8) {
                String(localized: "Internal server error. Response:\n\(responseStr)")
            } else {
                String(localized: "Internal server error")
            }
        case .badGateway:
            String(localized: "Bad gateway")
        case .couldntGetHost:
            String(localized: "Couldn't get host")
        case .couldntGenerateChallengeData:
            String(localized: "Couldn't generate passkey challenge data")
        case .missingCredential:
            String(localized: "Couldn't get Passkey credential")
        case .missingAssertion:
            String(localized: "Couldn't get Passkey assertion")
        }
    }
}
