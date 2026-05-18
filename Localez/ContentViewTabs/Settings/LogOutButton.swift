//
//  LogOutButton.swift
//  Localez
//
//  Created by Leo Wehrfritz on 18.05.26.
//

import SwiftUI
import EasyErrorHandling

struct LogOutButton: View {
    
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    @State private var showConfirmationDialog: Bool = false
    
    var body: some View {
        Button("Log Out", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive) {
            self.showConfirmationDialog = true
        }
        .foregroundStyle(.red)
        .confirmationDialog("Log out?", isPresented: self.$showConfirmationDialog) {
            Button("Yes", role: .destructive, action: self.logOut)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Your account will remain active.")
        }
    }
    
    func logOut() {
        Task {
            do {
                try await self.connectionHandler.logout()
            } catch {
                self.errorHandler.handle(error, while: "logging out")
            }
        }
    }
}

#Preview {
    LogOutButton()
        .withMockEnvironment()
}
