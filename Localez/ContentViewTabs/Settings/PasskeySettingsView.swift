//
//  PasskeySettingsView.swift
//  Localez
//
//  Created by Leo Wehrfritz on 18.05.26.
//

import SwiftUI
import EasyErrorHandling
import Localez_API

struct PasskeySettingsView: View {
    
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    let me: MeResponse
    
    @State var registeredPasskeys: [PasskeyResponse] = []
    
    @State private var isLoading: Bool = true
    
    @State private var showPasskeyRemovalDialog: Bool = false
    @State private var passkeyToRemove: PasskeyResponse?
    @State private var waitingForRemovalOf: String? = nil
    
    @State private var showPasskeyNameDialog: Bool = false
    @State private var newPasskeyName: String = ""
    @State private var registrationRunning: Bool = false
    
    var body: some View {
        List {
            if self.registeredPasskeys.isEmpty {
                if self.isLoading {
                    ProgressView()
                        .listRowBackground(EmptyView())
                        .frame(maxWidth: .infinity)
                } else {
                    ContentUnavailableView("No passkeys configured yet", systemImage: "person.badge.key")
                }
            } else {
                ForEach(self.registeredPasskeys) { passkey in
                    HStack {
                        Text(passkey.name)
                            .monospaced()
                        Spacer()
                        Button("Remove", systemImage: "trash", role: .destructive) {
                            self.passkeyToRemove = passkey
                            self.showPasskeyRemovalDialog = true
                        }
                        .foregroundStyle(.red)
                        .disabled(self.waitingForRemovalOf == passkey.id)
                    }
                    .confirmationDialog("Remove passkey \(self.passkeyToRemove?.name ?? "unnamed")?", isPresented: self.$showPasskeyRemovalDialog, presenting: self.$passkeyToRemove) { passkey in
                        Button("Yes", role: .destructive, action: self.removePasskey)
                    } message: { passkey in
                        Text("Remove passkey \(self.passkeyToRemove?.name ?? "unnamed")?")
                    }
                }
            }
            
            Section("Add passkey") {
                Button("Add passkey", systemImage: "plus") {
                    self.showPasskeyNameDialog = true
                }
                .disabled(self.registrationRunning)
                .alert("Passkey name", isPresented: self.$showPasskeyNameDialog) {
                    TextField("iPhone", text: self.$newPasskeyName)
                    Button("Confirm", action: self.registerPasskey)
                        .disabled(self.newPasskeyName.isEmpty)
                }
            }
        }
        .task(self.getRegisteredPasskeys)
        .throwingRefreshable(taskDescription: "reloading registered passkeys", self.getRegisteredPasskeys)
    }
    
    func getRegisteredPasskeys() async {
        withAnimation {
            self.isLoading = true
        }
        do {
            let keys: [PasskeyResponse] = try await self.connectionHandler.apiHandler.get()
            withAnimation {
                self.registeredPasskeys = keys
            }
        } catch {
            self.errorHandler.handle(error, while: "loading registered passkeys")
        }
        withAnimation {
            self.isLoading = false
        }
    }
    
    func registerPasskey() {
        withAnimation {
            self.registrationRunning = true
        }
        Task {
            do {
                try await self.connectionHandler.apiHandler.registerPasskey(username: self.me.username, passkeyName: self.newPasskeyName)
                await self.getRegisteredPasskeys()
            } catch {
                self.errorHandler.handle(error, while: "registering passkey")
            }
            withAnimation {
                self.registrationRunning = false
            }
        }
    }
    
    func removePasskey() {
        guard let passkeyToRemove else {
            self.errorHandler.handle("Couldn't get passkey to remove", while: "removing passkey")
            return
        }
        withAnimation {
            self.waitingForRemovalOf = passkeyToRemove.id
        }
        Task {
            do {
                try await self.connectionHandler.apiHandler.delete(passkeyToRemove)
                await self.getRegisteredPasskeys()
            } catch {
                self.errorHandler.handle(error, while: "removing passkey")
            }
            withAnimation {
                self.waitingForRemovalOf = nil
            }
        }
    }
}

#Preview {
    PasskeySettingsView(me: .mockAdmin)
        .withMockEnvironment()
}
