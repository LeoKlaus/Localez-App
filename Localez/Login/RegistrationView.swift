//
//  RegistrationView.swift
//  Localez
//
//  Created by Leo Wehrfritz on 17.05.26.
//

import SwiftUI
import EasyErrorHandling
import Localez_API

struct RecoveryWordWrapper: Identifiable {
    let id = UUID()
    let words: [String]
}

struct RegistrationView: View {
    
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var showPasswordWarning = false
    
    @State private var agreedToPp = false
    
    @State private var recoveryWords: RecoveryWordWrapper?
    @State private var newInstance: ConnectedInstance?
    @State private var response: RegisterResponse?
    
    var body: some View {
        VStack {
            Text("Create an account")
                .bold()
                        
            TextField("Username", text: self.$username)
                .textContentType(.username)
#if os(iOS)
                .textInputAutocapitalization(.never)
#endif
            
            SecureField("Password", text: self.$password)
                .textContentType(.newPassword)
            
            SecureField("Confirm password", text: self.$confirmPassword)
                .textContentType(.newPassword)
                .onSubmit(self.register)
            
            if showPasswordWarning {
                Text("Passwords do not match.")
                    .foregroundStyle(.red)
            }
            
            Toggle(isOn: self.$agreedToPp) {
                HStack(spacing: 0) {
                    Text("I agree to the ")
                    Link("privacy policy", destination: self.connectionHandler.apiHandler.baseURL.appending(path: "/legal/privacy"))
                }
            }
            .toggleStyle(.switch)
            .padding()
            
            Button("Register", action: self.register)
                .glassProminentButtonStyleIfAvailable()
                .padding()
                .disabled(self.username.isEmpty || self.password.isEmpty || self.confirmPassword.isEmpty || !self.agreedToPp)
                        
            SwitchServerLink()
        }
        .textFieldStyle(.roundedBorder)
        .padding()
        .frame(maxWidth: 500)
        .sheet(item: self.$recoveryWords, onDismiss: self.finishRegistration) { wrapper in
            RecoveryWordDisplayView(words: wrapper.words)
                .presentationDetents([.medium, .large])
        }
    }
    
    func register() {
        guard self.password == self.confirmPassword else {
            withAnimation {
                self.showPasswordWarning = true
            }
            return
        }
        
        withAnimation {
            self.showPasswordWarning = false
        }
        Task {
            do {
                let (response, instance, error) = try await self.connectionHandler.startRegistration(username: self.username, password: self.password)
                
                if let error {
                    self.errorHandler.handle(error, while: "saving token")
                }
                
                self.recoveryWords = RecoveryWordWrapper(words: response.recoveryWords)
                self.newInstance = instance
                self.response = response
            } catch {
                self.errorHandler.handle(error, while: "signing up")
            }
        }
    }
    
    func finishRegistration() {
        guard let newInstance, let response else {
            self.errorHandler.handle("Couldn't get login info. Your account was still created.", while: "logging in")
            return
        }
        Task {
            do {
                self.errorHandler.showInfo("Account created!")
                try self.connectionHandler.applyNewInstance(instance: newInstance, accessToken: response.accessToken, refreshToken: response.refreshToken)
            } catch {
                self.errorHandler.handle(error, while: "logging in")
            }
        }
    }
}

#Preview {
    RegistrationView()
        .withMockEnvironment()
}
