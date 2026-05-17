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
    
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    @State private var projects: [ProjectResponse] = []
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, \(self.connectionHandler.currentInstance?.username ?? "")!")
            
            ScrollView {
                ForEach(self.projects) { project in
                    Text(project.name)
                }
            }
            
            Button("Log Out") {
                Task {
                    do {
                        try await self.connectionHandler.logout()
                    } catch {
                        self.errorHandler.handle(error, while: "logging out")
                    }
                }
            }
        }
        .padding()
        .throwingTask(taskDescription: "loading projects") {
            let loadedProjects: [ProjectResponse] = try await self.connectionHandler.apiHandler.get()
            
            withAnimation {
                self.projects = loadedProjects
            }
        }
    }
}

#Preview {
    ContentView()
        .withMockEnvironment()
}
