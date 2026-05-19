//
//  ProjectList.swift
//  Localez
//
//  Created by Leo Wehrfritz on 18.05.26.
//

import SwiftUI
import EasyErrorHandling
import Localez_API

struct ProjectList: View {
    
    @AppStorage(.userDefaults(.activeInstance), store: .localez)
    var activeInstance: ConnectedInstance? = nil
    
    @Environment(NavigationHandler.self) var navigationHandler
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    @State private var projects: [ProjectResponse] = []
    
    @State private var isLoadingProjects: Bool = true
    
    @State private var selectedProject: ProjectResponse?
    
    var body: some View {
        @Bindable var navigationHandler = self.navigationHandler
        NavigationStack {
            List(self.projects) { project in
                Button {
                    do {
                        try self.activeInstance?.setSelectedProject(project)
                    } catch {
                        self.errorHandler.handle(error, while: "setting selected project")
                    }
                } label: {
                    ProjectListItem(project: project)
                }
            }
            .navigationTitle("Projects")
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

#Preview {
    ProjectList()
        .withMockEnvironment()
}
