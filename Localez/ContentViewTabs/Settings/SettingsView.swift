//
//  SettingsView.swift
//  Localez
//
//  Created by Leo Wehrfritz on 18.05.26.
//

import SwiftUI
import EasyErrorHandling

enum SettingsItem {
    case auth
}

struct SettingsView: View {
    
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    @State private var settingsTab: SettingsItem?
    
    var body: some View {
        NavigationStack {
            List {
                SwitchProjectButton()
                
                Section("Your account") {
                    NavigationLink(destination:  AuthSettingsView()) {
                        Label("Manage account", systemImage: "person.crop.circle")
                    }
                    
                    LogOutButton()
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .withMockEnvironment()
}
