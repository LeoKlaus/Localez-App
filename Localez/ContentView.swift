//
//  ContentView.swift
//  Localez
//
//  Created by Leo Wehrfritz on 17.05.26.
//

import SwiftUI
import EasyErrorHandling

struct ContentView: View {
    
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
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
    }
}

#Preview {
    ContentView()
        .withMockEnvironment()
}
