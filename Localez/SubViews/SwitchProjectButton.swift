//
//  SwitchProjectButton.swift
//  Localez
//
//  Created by Leo Wehrfritz on 19.05.26.
//

import SwiftUI
import Localez_API
import EasyErrorHandling

struct SwitchProjectButton: View {
    
    @AppStorage(.userDefaults(.activeInstance), store: .localez)
    var activeInstance: ConnectedInstance? = nil
    
    @Environment(NavigationHandler.self) var navigationHandler
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    @State private var showProjectsSheet: Bool = false
    
    var body: some View {
        Button {
            self.showProjectsSheet = true
        } label: {
            Label("Switch project", systemImage: "questionmark.folder")
        }
        .sheet(isPresented: self.$showProjectsSheet) {
            ProjectList()
                .presentationDetents([.medium, .large])
        }
        .onChange(of: self.activeInstance?.selectedProject) {
            self.showProjectsSheet = false
        }
    }
}

#Preview("List") {
    List {
        SwitchProjectButton()
    }
    .listStyle(.sidebar)
    .withMockEnvironment()
}

#Preview("Toolbar") {
    NavigationStack {
        VStack {
            
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                SwitchProjectButton()
            }
        }
    }
    .withMockEnvironment()
}
