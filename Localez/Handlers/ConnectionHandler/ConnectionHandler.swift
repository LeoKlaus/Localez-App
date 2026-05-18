//
//  ConnectionHandle.swift
//  Localez
//
//  Created by Leo Wehrfritz on 17.05.26.
//

import Foundation
import OSLog
import Localez_API
import EasyErrorHandling

@Observable
class ConnectionHandler {
    
    public static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ConnectionHandler.self)
    )
    
    public var apiHandler: LocalezApiHandler
    
    public var currentInstance: ConnectedInstance?
    
    public var isLoggedIn: Bool {
        self.currentInstance != nil
    }
    
    init() {
        do {
            let activeInstance = try ConnectedInstance.getActiveInstance()
            let refreshToken = try activeInstance.getToken()
            
            self.apiHandler = LocalezApiHandler(
                baseURL: activeInstance.serverURL,
                refreshToken: refreshToken,
                tokenRefreshHook: activeInstance.save
            )
            self.currentInstance = activeInstance
        } catch {
            if case ConnectedInstanceError.noActiveInstance = error {
                Self.logger.debug("No active instance set")
            } else {
                ErrorHandler.shared.handle(error, while: "instantiating ConnectionHandler")
            }
            
            self.apiHandler = LocalezApiHandler(baseURL: URL(string: "https://translate.wehrfritz.me")!)
        }
    }
    
    init(apiHandler: LocalezApiHandler) {
        self.apiHandler = apiHandler
    }
    
    func switchServerBaseURL(_ newURL: URL) {
        self.apiHandler = LocalezApiHandler(baseURL: newURL)
    }
    
    func login(_ response: TokenResponse, username: String) throws {
        let newInstance = ConnectedInstance(
            serverURL: self.apiHandler.baseURL,
            username: username
        )
        
        try self.applyNewInstance(instance: newInstance, accessToken: response.accessToken, refreshToken: response.refreshToken)
    }
    
    func logout() async throws {
        try await self.apiHandler.logout()
        try self.currentInstance?.delete()
        self.currentInstance = nil
    }
    
    func createInstance(username: String, password: String, totpToken: String? = nil) async throws {
        let response = try await self.apiHandler.loginUser(
            username: username,
            password: password,
            totpCode: totpToken
        )
        try self.login(response, username: username)
    }
    
    func applyNewInstance(instance: ConnectedInstance, accessToken: String, refreshToken: String) throws {
        try instance.save(refreshToken: refreshToken)
        try instance.markActive()
        self.currentInstance = instance
        
        self.apiHandler = LocalezApiHandler(
            baseURL: self.apiHandler.baseURL,
            accessToken: accessToken,
            refreshToken: refreshToken,
            tokenRefreshHook: instance.save
        )
    }
    
    func startRegistration(username: String, password: String) async throws -> (RegisterResponse, ConnectedInstance, Error?) {
        let (response, error) = try await self.apiHandler.registerUser(username: username, password: password)
        
        let newInstance = ConnectedInstance(
            serverURL: self.apiHandler.baseURL,
            username: username
        )
        
        return (response, newInstance, error)
    }
    
    func deleteAccount() async throws {
        _ = try await self.apiHandler.sendRequest(method: .DELETE, endpoint: .me)
        try self.currentInstance?.delete()
        self.currentInstance = nil
    }
}
