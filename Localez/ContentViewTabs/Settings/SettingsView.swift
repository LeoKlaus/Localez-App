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
        NavigationSplitView {
            List(selection: self.$settingsTab) {
                Section("Your account") {
                    Label("Manage account", systemImage: "person.crop.circle").tag(SettingsItem.auth)
                    
                    LogOutButton()
                }
            }
            .navigationTitle("Settings")
        } detail: {
            switch self.settingsTab {
            case .auth:
                AuthSettingsView()
            case .none:
                Text("Select a settings Item")
            }
        }
    }
}

#Preview {
    SettingsView()
        .withMockEnvironment()
}
