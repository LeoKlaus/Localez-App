//
//  ProjectStringList.swift
//  Localez
//
//  Created by Leo Wehrfritz on 19.05.26.
//

import SwiftUI
import Localez_API
import EasyErrorHandling

struct ProjectStringList: View {
    
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    let project: ProjectResponse
    let language: String
    
    @State private var strings: [LocalizationWithKeyResponse] = []
    @State private var isLoadingStrings: Bool = true
    
    var body: some View {
        List {
            if strings.isEmpty {
                if self.isLoadingStrings {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowBackground(EmptyView())
                } else {
                    ContentUnavailableView("No strings found", systemImage: "xmark")
                }
            } else {
                ForEach(self.$strings) { $string in
                    LocalizationWithKeyListItem(string: $string)
                }
            }
        }
        .task(self.getStrings)
        .refreshable(action: self.getStrings)
    }
    
    func getStrings() async {
        withAnimation {
            self.isLoadingStrings = true
        }
        
        do {
            let strings: [LocalizationWithKeyResponse] = try await self.connectionHandler.apiHandler.get(from: .projectLocalizations(id: self.project.id, language: self.language))
            withAnimation {
                self.strings = strings
            }
        } catch {
            self.errorHandler.handle(error, while: "loading localizations for \(self.project.name)")
        }
        
        withAnimation {
            self.isLoadingStrings = false
        }
    }
}

#Preview {
    ProjectStringList(project: .mock, language: "de")
        .withMockEnvironment()
}
