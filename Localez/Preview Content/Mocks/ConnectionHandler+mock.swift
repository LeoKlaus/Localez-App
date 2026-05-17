//
//  ConnectionHandler+mock.swift
//  Localez
//
//  Created by Leo Wehrfritz on 17.05.26.
//

import Foundation
import Localez_API
import OSLog

enum MockApiError: Error {
    case notImplemented
    case missingBody
}

@Observable
class MockConnectionHandler: ConnectionHandler {
    override init() {
        super.init(apiHandler: MockApiHandler())
    }
}


nonisolated class MockApiHandler: LocalezApiHandler {
    init() {
        super.init(
            baseURL: URL(string: "https://translate.wehrfritz.me")!,
            tokenRefreshHook: { refresh in
                Self.logger.debug("Updated tokens: (\(refresh)")
            }
        )
    }
    
    override func sendRequest(method: HttpMethod, endpoint: ApiEndpoint, body: Data? = nil, queryItems: [URLQueryItem] = [], isRetry: Bool = false, isAuthenticated: Bool = true) async throws -> Data {
        switch endpoint {
        case .login:
            guard let body else {
                throw MockApiError.missingBody
            }
            let request = try Self.jsonDecoder.decode(LoginRequest.self, from: body)
            
            if request.username.lowercased() == "admin" && request.totpCode == nil {
                throw ApiError.totpRequired
            }
            
            return try Self.jsonEncoder.encode(TokenResponse(accessToken: "mock-access", refreshToken: "mock-refresh"))
        case .register:
            guard let body else {
                throw MockApiError.missingBody
            }
            
            _ = try Self.jsonDecoder.decode(RegisterRequest.self, from: body)
            
            return try Self.jsonEncoder.encode(
                RegisterResponse(
                    accessToken: "mock-access",
                    refreshToken: "mock-refresh",
                    recoveryWords: [
                        "bandicoy",
                        "gospelly",
                        "subrule",
                        "sovranty",
                        "entasis",
                        "pimelite",
                        "cobbler",
                        "omani",
                        "salwey",
                        "owling",
                        "mutely",
                        "reggie"
                    ]
                )
            )
        default:
            throw MockApiError.notImplemented
        }
    }
}

extension ConnectionHandler {
    static let mock: ConnectionHandler = MockConnectionHandler()
}
