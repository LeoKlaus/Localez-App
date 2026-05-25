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
    
    @State private var isLoggingOut: Bool = false
    @State private var showConfirmationDialog: Bool = false
    
    var body: some View {
        Button(role: .destructive) {
            self.showConfirmationDialog = true
        } label: {
            Label {
                Text("Log out")
            } icon: {
                if self.isLoggingOut {
                    ProgressView()
                } else {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .disabled(self.isLoggingOut)
        .foregroundStyle(.red)
        .confirmationDialog("Log out?", isPresented: self.$showConfirmationDialog) {
            Button("Yes", role: .destructive, action: self.logOut)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Your account will remain active.")
        }
    }
    
    func logOut() {
        withAnimation {
            self.isLoggingOut = true
        }
        Task {
            do {
                try await self.connectionHandler.logout()
            } catch {
                self.errorHandler.handle(error, while: "logging out")
            }
        }
        withAnimation {
            self.isLoggingOut = false
        }
    }
}

#Preview {
    LogOutButton()
        .withMockEnvironment()
}
