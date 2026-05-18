//
//  ConnectionHandler+mock.swift
//  Localez
//
//  Created by Leo Wehrfritz on 17.05.26.
//

import Foundation
import Localez_API
import OSLog

enum MockApiError: Error, LocalizedError {
    case notImplemented
    case missingBody
    
    var errorDescription: String? {
        switch self {
        case .notImplemented:
            "Not implemented"
        case .missingBody:
            "Request missing body"
        }
    }
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
    
    private var user: MeResponse = .mockInsecure
    
    override func sendRequest(method: HttpMethod, endpoint: ApiEndpoint, body: Data? = nil, queryItems: [URLQueryItem] = [], isRetry: Bool = false, isAuthenticated: Bool = true) async throws -> Data {
        
        try await Task.sleep(for: .milliseconds(Int.random(in: 300...1000)))
        
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
                RegisterResponse.mock
            )
        case .me:
            return try Self.jsonEncoder.encode(
                user
            )
        case .setupTotp:
            return try Self.jsonEncoder.encode(
                TotpSetupResponse.mock
            )
        case .verifyTotp:
            self.user = .mock2fa
            return Data()
        case .disableTotp:
            self.user = .mockInsecure
            return Data()
        default:
            throw MockApiError.notImplemented
        }
    }
}

extension ConnectionHandler {
    static let mock: ConnectionHandler = MockConnectionHandler()
}
