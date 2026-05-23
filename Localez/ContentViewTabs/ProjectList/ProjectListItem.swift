//
//  ProjectListItem.swift
//  Localez
//
//  Created by Leo Wehrfritz on 18.05.26.
//

import SwiftUI
import EasyErrorHandling
import Localez_API


struct ProjectListItem: View {
    
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    let project: ProjectResponse
    
    var body: some View {
        HStack {
            ProjectIcon(project: self.project)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text(self.project.name)
                    .bold()
                Text(self.project.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(self.project.sourceLanguage)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .background(.gray.opacity(0.25))
                .clipShape(.capsule)
        }
    }
}

#Preview("With Icon") {
    List {
        ProjectListItem(project: .mock)
    }
    .withMockEnvironment()
}

#Preview("Wthout Icon") {
    List {
        ProjectListItem(project: .mock3)
    }
    .withMockEnvironment()
}
