//
//  ContentView.swift
//  Localez
//
//  Created by Leo Wehrfritz on 17.05.26.
//

import SwiftUI
import EasyErrorHandling
import Localez_API

struct ContentView: View {
    
    @AppStorage(.userDefaults(.activeInstance), store: .localez)
    var activeInstance: ConnectedInstance? = nil
    
    @Environment(NavigationHandler.self) var navigationHandler
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    var body: some View {
        @Bindable var navigationHandler = self.navigationHandler
        
        TabView(selection: $navigationHandler.currentTab) {
            if let currentProject = self.activeInstance?.selectedProject {
                Tab("Strings", systemImage: "text.alignleft", value: .strings) {
                    ProjectDetailView(project: currentProject)
                        .id(self.activeInstance?.selectedProject)
                }
            } else {
                Tab("Projects", systemImage: "folder", value: .projects) {
                    ProjectList()
                }
            }
            
            Tab("Settings", systemImage: "gear", value: .settings) {
                SettingsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    ContentView()
        .withMockEnvironment()
}
