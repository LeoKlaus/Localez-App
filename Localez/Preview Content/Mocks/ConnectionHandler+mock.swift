//
//  ConnectionHandler+mock.swift
//  Localez
//
//  Created by Leo Wehrfritz on 17.05.26.
//

import Foundation
import Localez_API
import OSLog
import UIKit

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
    
    private var registeredPasskeys = [
        PasskeyResponse.mock
    ]
    
    private var projects: [ProjectResponse] = [
        .mock,
        .mock2,
        .mock3
    ]
    
    override func sendRequest(method: HttpMethod, endpoint: ApiEndpoint, body: Data? = nil, queryItems: [URLQueryItem] = [], isRetry: Bool = false, isAuthenticated: Bool = true) async throws -> Data {
        
        Self.logger.debug("Simulating \(method.rawValue, privacy: .public) request to \(endpoint.path, privacy: .public)")
        
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
        case .passkeyCredentials:
            return try Self.jsonEncoder.encode(self.registeredPasskeys)
        case .passkeyCredential(let id):
            guard method == .DELETE else {
                throw ApiError.badRequest(response: nil)
            }
            self.registeredPasskeys.removeAll(where: {
                $0.id == id
            })
            return Data()
        case .projects:
            return try Self.jsonEncoder.encode(self.projects)
        case .project(let id):
            if let project = self.projects.first(where: {$0.id == id}) {
                return try Self.jsonEncoder.encode(project)
            } else {
                throw ApiError.notFound
            }
        case .projectIcon(let id):
            if let project = self.projects.first(where: {$0.id == id}) {
                if project == .mock, let imgData = await UIImage(resource: .paperparrotIcon).pngData() {
                    return imgData
                } else if project == .mock2, let imgData = await UIImage(resource: .plappaIcon).pngData() {
                    return imgData
                }
            }
            throw ApiError.notFound
        default:
            throw MockApiError.notImplemented
        }
    }
}

extension ConnectionHandler {
    static let mock: ConnectionHandler = MockConnectionHandler()
}
