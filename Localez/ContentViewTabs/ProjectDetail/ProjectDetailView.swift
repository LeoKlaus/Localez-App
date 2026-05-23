//
//  ProjectDetailView.swift
//  Localez
//
//  Created by Leo Wehrfritz on 19.05.26.
//

import SwiftUI
import Localez_API
import EasyErrorHandling

struct ProjectDetailView: View {
    
    @Environment(NavigationHandler.self) var navigationHandler
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    let project: ProjectResponse
    
    @State private var projectStats: ProjectStats?
    @State private var isLoadingStats: Bool = true
    
    var body: some View {
        @Bindable var navigationHandler = self.navigationHandler
        NavigationStack(path: $navigationHandler.projectListPath) {
            List {
                if self.projectStats?.languages.isEmpty ?? true {
                    if self.isLoadingStats {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .listRowBackground(EmptyView())
                    } else {
                        ContentUnavailableView("No translations", systemImage: "xmark")
                    }
                } else {
                    Section {
                        ForEach(self.projectStats?.languages ?? [], id: \.self) { language in
                            NavigationLink(value: language.language) {
                                LanguageStatListItem(languageStats: language, total: self.projectStats?.totalStrings ?? 0)
                            }
                        }
                    } header: {
                        Text("Languages")
                    } footer: {
                        HStack {
                            Circle().foregroundStyle(.green)
                                .frame(maxHeight: 10)
                            Text("Translated")
                                .font(.caption)
                            
                            Circle().foregroundStyle(.yellow)
                                .frame(maxHeight: 10)
                            Text("Needs review")
                                .font(.caption)
                            
                            Circle().foregroundStyle(.gray)
                                .frame(maxHeight: 10)
                            Text("Missing")
                                .font(.caption)
                        }
                    }
                }
            }
            .task(self.getStats)
            .refreshable(action: self.getStats)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        ProjectIcon(project: self.project)
                            .frame(width: 40, height: 40)
                        Text(self.project.name)
                            .bold()
                    }
                }
                
                ToolbarItem(placement: .secondaryAction) {
                    SwitchProjectButton()
                }
            }
            .navigationDestination(for: String.self) { language in
                ProjectStringList(project: self.project, language: language)
            }
        }
    }
    
    func getStats() async {
        withAnimation {
            self.isLoadingStats = true
        }
        do {
            let stats: ProjectStats = try await self.connectionHandler.apiHandler.get(from: .projectStats(id: self.project.id))
            
            withAnimation {
                self.projectStats = stats
            }
        } catch {
            self.errorHandler.handle(error, while: "loading project stats for \(self.project.name)")
        }
        withAnimation {
            self.isLoadingStats = false
        }
    }
}

#Preview {
    ProjectDetailView(project: .mock)
        .withMockEnvironment()
}
