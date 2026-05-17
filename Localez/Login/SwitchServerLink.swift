//
//  SwitchServerLink.swift
//  Localez
//
//  Created by Leo Wehrfritz on 17.05.26.
//

import SwiftUI
import Localez_API

struct SwitchServerLink: View {
    
    @Environment(ConnectionHandler.self) var connectionHandler
    
    var body: some View {
        NavigationLink(destination: SwitchServerView()) {
            VStack {
                Text("Connected to \(self.connectionHandler.apiHandler.baseURL.host() ?? self.connectionHandler.apiHandler.baseURL.absoluteString)")
                NavigationLink("Switch server?", destination: SwitchServerView())
                    .foregroundStyle(.tint)
            }
        }
        .padding(.top)
        .foregroundStyle(.primary)
        .font(.footnote)
    }
}

#Preview {
    NavigationStack {
        SwitchServerLink()
    }
    .withMockEnvironment()
}
