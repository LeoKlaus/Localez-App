//
//  SwitchProjectButton.swift
//  Localez
//
//  Created by Leo Wehrfritz on 19.05.26.
//

import SwiftUI
import Localez_API
import EasyErrorHandling

struct ProjectSelectionSheet: View {
    
    @Environment(\.dismiss) var dismiss
    
    @AppStorage(.userDefaults(.activeInstance), store: .localez)
    var activeInstance: ConnectedInstance? = nil
    
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    @State private var projects: [ProjectResponse] = []
    
    @State private var isLoadingProjects: Bool = true
    
    var body: some View {
        List(self.projects) { project in
            Button {
                do {
                    try self.activeInstance?.setSelectedProject(project)
                    self.dismiss()
                } catch {
                    self.errorHandler.handle(error, while: "setting selected project")
                }
            } label: {
                ProjectListItem(project: project)
            }
            .disabled(project.id == self.activeInstance?.selectedProject?.id)
        }
        .task(self.getProjects)
    }
    
    func getProjects() async {
        withAnimation {
            self.isLoadingProjects = true
        }
        do {
            let projects: [ProjectResponse] = try await self.connectionHandler.apiHandler.get()
            withAnimation {
                self.projects = projects
            }
        } catch {
            self.errorHandler.handle(error, while: "loading projects")
        }
        withAnimation {
            self.isLoadingProjects = false
        }
    }
}

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
            ProjectSelectionSheet()
                .presentationDetents([.medium, .large])
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
