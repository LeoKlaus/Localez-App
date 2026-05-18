//
//  AuthSettingsView.swift
//  Localez
//
//  Created by Leo Wehrfritz on 18.05.26.
//

import SwiftUI
import EasyErrorHandling
import Localez_API

struct AuthSettingsView: View {
    
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    @State var me: MeResponse?
    
    @State private var showDeleteConfirmation: Bool = false
    
    var body: some View {
        List {
            Section("Profile") {
                if let me {
                    HStack {
                        Text("Username:")
                        Spacer()
                        Text(me.username)
                            .bold()
                    }
                    HStack {
                        Text("Role:")
                        Spacer()
                        Text(me.globalRole.rawValue)
                            .bold()
                    }
                } else {
                    ProgressView()
                        .task(self.getMe)
                }
                
                LogOutButton()
            }
            
            Section("Security") {
                NavigationLink(destination: ChangePasswordView()) {
                    Label("Change password", systemImage: "key")
                }
                
                if let bindingMe = Binding(self.$me) {
                    NavigationLink(destination: PasskeySettingsView(me: bindingMe.wrappedValue)) {
                        if bindingMe.wrappedValue.passkeysConfigured {
                            Label("Manage passkeys", systemImage: "person.badge.key")
                        } else {
                            Label("Add passkey", systemImage: "person.badge.key")
                        }
                    }
                    .transition(.move(edge: .top))
                    
                    TwoFactorAuthSettingsButton(me: bindingMe)
                        .transition(.move(edge: .top))
                }
            }
            
            Section("Danger zone") {
                Button("Delete account", systemImage: "trash") {
                    self.showDeleteConfirmation = true
                }
                .bold()
                .alert("Delete your account?", isPresented: self.$showDeleteConfirmation) {
                    Button("Yes", role: .destructive, action: self.deleteAccount)
                } message: {
                    Text("Your account will be permanently deleted.")
                }
            }
            .foregroundStyle(.red)
        }
    }
    
    func getMe() async {
        do {
            let user: MeResponse = try await self.connectionHandler.apiHandler.get()
            withAnimation {
                self.me = user
            }
        } catch {
            self.errorHandler.handle(error, while: "loading user details")
        }
    }
    
    func deleteAccount() {
        Task {
            do {
                try await self.connectionHandler.deleteAccount()
            } catch {
                self.errorHandler.handle(error, while: "deleting account")
            }
        }
    }
}

#Preview("Admin") {
    NavigationStack {
        AuthSettingsView()
    }
    .withMockEnvironment()
}
