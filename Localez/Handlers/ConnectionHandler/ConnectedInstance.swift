//
//  ConnectedInstance.swift
//  Localez
//
//  Created by Leo Wehrfritz on 17.05.26.
//

import Foundation
import Localez_API

enum ConnectedInstanceError: LocalizedError {
    case couldntAccessUserdefaults
    case instanceNotFound
    case noActiveInstance
    case tokenDataNotFound
    case couldntDecodeToken
    
    public var errorDescription: String? {
        switch self {
        case .couldntAccessUserdefaults:
            String(localized: "Couldn't access UserDefaults")
        case .instanceNotFound:
            String(localized: "No matching instance found")
        case .noActiveInstance:
            String(localized: "No instance is marked active")
        case .tokenDataNotFound:
            String(localized: "Couldn't find token data")
        case .couldntDecodeToken:
            String(localized: "Couldn't decode token data")
        }
    }
}

struct ConnectedInstance: Codable, Hashable, Sendable, Identifiable {
    
    let id: String
    var displayName: String {
        "\(username)@\(serverURL.host() ?? "")"
    }
    let serverURL: URL
    let userId: String
    let username: String
    private(set) var selectedProject: ProjectResponse?
    
    init(serverURL: URL, username: String, userId: String) {
        self.id = UUID().uuidString
        self.serverURL = serverURL
        self.username = username
        self.userId = userId
    }
    

    mutating func setSelectedProject(_ project: ProjectResponse?) throws {
        self.selectedProject = project
        
        guard let defaults = UserDefaults.localez else {
            throw ConnectedInstanceError.couldntAccessUserdefaults
        }
        
        var connectedInstances: [String:ConnectedInstance] = [:]
        
        if let instancesData = defaults.string(forKey: .userDefaults(.connectedInstances)) {
            connectedInstances = try JSONDecoder().decode([String:ConnectedInstance].self, from: Data(instancesData.utf8))
        }
        
        connectedInstances[self.id] = self
        
        defaults.set((self as ConnectedInstance?).rawValue, forKey: .userDefaults(.activeInstance))
        defaults.set(connectedInstances.rawValue, forKey: .userDefaults(.connectedInstances))
    }
    
    /**
     Save this instance to userdefaults
     - Parameter token: Auth token for this instance
     */
    func save(refreshToken: String) throws {
        guard let defaults = UserDefaults.localez else {
            throw ConnectedInstanceError.couldntAccessUserdefaults
        }
        
        var connectedInstances: [String:ConnectedInstance] = [:]
        
        if let instancesData = defaults.string(forKey: .userDefaults(.connectedInstances)) {
            connectedInstances = try JSONDecoder().decode([String:ConnectedInstance].self, from: Data(instancesData.utf8))
        }
        
        try KeychainHandler.standard.save(Data(refreshToken.utf8), service: self.serverURL.absoluteString, account: self.username)
        
        connectedInstances[self.id] = self
        defaults.set(connectedInstances.rawValue, forKey: .userDefaults(.connectedInstances))
    }
    
    /**
     Get the auth token for this instance
     - Returns: The refresh token
     */
    func getToken() throws -> String {
        guard let refreshTokenData = KeychainHandler.standard.read(service: self.serverURL.absoluteString, account: self.username) else {
            throw ConnectedInstanceError.tokenDataNotFound
        }
        
        guard let refreshToken = String(data: refreshTokenData, encoding: .utf8) else {
            throw ConnectedInstanceError.couldntDecodeToken
        }
        
        return refreshToken
    }
    
    /**
     Removes this instance and its stored token
     */
    func delete() throws {
        guard let defaults = UserDefaults.localez else {
            throw ConnectedInstanceError.couldntAccessUserdefaults
        }
        
        var connectedInstances = try Self.getConnectedInstances()
        var activeInstance: ConnectedInstance? = try Self.getActiveInstance()
        
        connectedInstances.removeValue(forKey: self.id)
        KeychainHandler.standard.delete(service: self.serverURL.absoluteString, account: self.username)
        
        if activeInstance?.id == self.id {
            activeInstance = connectedInstances.values.first
        }
        
        if let _ = activeInstance {
            defaults.set(activeInstance.rawValue, forKey: .userDefaults(.activeInstance))
        } else {
            defaults.set(nil, forKey: .userDefaults(.activeInstance))
        }
        defaults.set(connectedInstances.rawValue, forKey: .userDefaults(.connectedInstances))
    }
    
    func markActive() throws {
        guard let defaults = UserDefaults.localez else {
            throw ConnectedInstanceError.couldntAccessUserdefaults
        }
        
        defaults.set((self as ConnectedInstance?).rawValue, forKey: .userDefaults(.activeInstance))
    }
    
    /**
     Get the currently active instance
     - Returns: The currently active instance
     - Throws: `ConnectedInstanceError.instanceNotFound` if no instance is stored
     */
    static func getActiveInstance() throws -> ConnectedInstance {
        guard let defaults = UserDefaults.localez else {
            throw ConnectedInstanceError.couldntAccessUserdefaults
        }
        
        guard let instanceString = defaults.string(forKey: .userDefaults(.activeInstance)) else {
            throw ConnectedInstanceError.noActiveInstance
        }
        return try JSONDecoder().decode(ConnectedInstance.self, from: Data(instanceString.utf8))
    }
    
    /**
     Get all stored instances
     - Returns: List of all connected instances
     */
    static func getConnectedInstances() throws -> [String:ConnectedInstance] {
        guard let defaults = UserDefaults.localez else {
            throw ConnectedInstanceError.couldntAccessUserdefaults
        }
        
        guard let instancesString = defaults.string(forKey: .userDefaults(.connectedInstances)) else {
            throw ConnectedInstanceError.instanceNotFound
        }
        
        return try JSONDecoder().decode([String:ConnectedInstance].self, from: Data(instancesString.utf8))
    }
}

typealias ConnectedInstances = [String:ConnectedInstance]

extension ConnectedInstances: @retroactive RawRepresentable where Self == [String:ConnectedInstance] {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(ConnectedInstances.self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
