//
//  ProjectListItem.swift
//  Localez
//
//  Created by Leo Wehrfritz on 18.05.26.
//

import SwiftUI
import EasyErrorHandling
import Localez_API

enum ProjectIconError: Error, LocalizedError {
    case invalidImageData
    
    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            String(localized: "Received invalid image data")
        }
    }
}

struct ProjectListItem: View {
    
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    let project: ProjectResponse
    
    @State private var icon: Image?
    
    var body: some View {
        HStack {
            Group {
                if let icon {
                    icon
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: "folder")
                        .resizable()
                        .scaledToFit()
                        .padding(5)
                        .foregroundStyle(.secondary)
                }
            }
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
        }.task(self.loadIcon)
    }
    
    func loadIcon() async {
        guard self.project.hasIcon && self.icon == nil else {
            return
        }
        
        do {
            let iconData = try await self.connectionHandler.apiHandler.sendRequest(method: .GET, endpoint: .projectIcon(id: self.project.id))
            guard let image = UIImage(data: iconData) else {
                throw ProjectIconError.invalidImageData
            }
            withAnimation {
                self.icon = Image(uiImage: image)
            }
        } catch {
            self.errorHandler.handle(error, while: "loading icon for \(project.name)")
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
