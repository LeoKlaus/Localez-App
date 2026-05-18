//
//  ChangePasswordView.swift
//  Localez
//
//  Created by Leo Wehrfritz on 18.05.26.
//

import SwiftUI
import EasyErrorHandling
import Localez_API

struct ChangePasswordView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmNewPassword: String = ""
    
    @State private var waitingForResponse: Bool = false
    
    var body: some View {
        List {
            Section("Current password") {
                SecureField("Current password", text: self.$currentPassword)
                    .textContentType(.password)
            }
            Section("New password") {
                SecureField("New password", text: self.$newPassword)
                    .textContentType(.newPassword)
                SecureField("Confirm password", text: self.$confirmNewPassword)
                    .textContentType(.newPassword)
            }
            
            Section {
                Button(action: self.changePassword) {
                    Label {
                        Text("Change password")
                    } icon: {
                        if self.waitingForResponse {
                            ProgressView()
                        } else {
                            Image(systemName: "key")
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 35)
                }
                .disabled(self.waitingForResponse || self.currentPassword.isEmpty || self.newPassword.isEmpty || self.confirmNewPassword.isEmpty)
                .glassProminentButtonStyleIfAvailable()
                .listRowBackground(
                    EmptyView()
                )
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        }
        .navigationTitle("Change password")
    }
    
    func changePassword() {
        guard newPassword == confirmNewPassword else {
            self.errorHandler.handle("Passwords don't match", while: "updating password")
            return
        }
        withAnimation {
            self.waitingForResponse = true
        }
        Task {
            do {
                _ = try await self.connectionHandler.apiHandler.patch(
                    UpdatePasswordRequest(
                        currentPassword: self.currentPassword,
                        newPassword: self.newPassword
                    )
                )
                self.dismiss()
                self.errorHandler.showInfo("Password changed!")
            } catch {
                self.errorHandler.handle(error, while: "updating password")
            }
            withAnimation {
                self.waitingForResponse = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChangePasswordView()
    }
    .withMockEnvironment()
}
