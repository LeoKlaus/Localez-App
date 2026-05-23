//
//  ProjectIcon.swift
//  Localez
//
//  Created by Leo Wehrfritz on 19.05.26.
//

import SwiftUI
import Localez_API
import EasyErrorHandling


enum ProjectIconError: Error, LocalizedError {
    case invalidImageData
    
    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            String(localized: "Received invalid image data")
        }
    }
}

struct ProjectIcon: View {
    
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    let project: ProjectResponse
    
    @State private var icon: Image?
    
    var body: some View {
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
        .task(self.loadIcon)
    }
    

    func loadIcon() async {
        guard self.project.hasIcon && self.icon == nil else {
            return
        }
        
        do {
            let iconData = try await self.connectionHandler.apiHandler.sendRequest(method: .GET, endpoint: .projectIcon(id: self.project.id))
            #if canImport(UIKit)
            guard let image = UIImage(data: iconData) else {
                throw ProjectIconError.invalidImageData
            }
            withAnimation {
                self.icon = Image(uiImage: image)
            }
            #else
            guard let image = NSImage(data: iconData) else {
                throw ProjectIconError.invalidImageData
            }
            withAnimation {
                self.icon = Image(nsImage: image)
            }
            #endif
        } catch {
            self.errorHandler.handle(error, while: "loading icon for \(project.name)")
        }
    }
}

#Preview {
    ProjectIcon(project: .mock)
        .withMockEnvironment()
        .frame(maxWidth: 100)
}
