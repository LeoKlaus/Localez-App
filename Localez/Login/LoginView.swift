//
//  LoginView.swift
//  Localez
//
//  Created by Leo Wehrfritz on 17.05.26.
//

import SwiftUI
import EasyErrorHandling
import Localez_API

struct LoginView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var totpToken: String = ""
    
    @State private var totpRequired: Bool = false
    
    @FocusState var isTotpFocused
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(.simpleIcon)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 150)
            
            Spacer()
            
            Text("Welcome to **Localez**")
                .font(Font.custom("AbyssinicaSIL-Regular", size: 18))
            
            Text("To get started, sign in with your account.")
                .foregroundStyle(.secondary)
            
            TextField("Username", text: self.$username)
                .textInputAutocapitalization(.never)
                .textContentType(.username)
            
            SecureField("Password", text: self.$password)
                .textContentType(.password)
                .onSubmit(self.signIn)
            
            if self.totpRequired {
                TextField("Authenticator code", text: self.$totpToken)
                    .textContentType(.oneTimeCode)
                    .keyboardType(.numberPad)
                    .onSubmit(self.signIn)
                    .focused(self.$isTotpFocused)
            }
            
            HStack {
                Button(action: self.signIn) {
                    Text("Sign in")
                        .frame(maxWidth: .infinity)
                }
                .glassProminentButtonStyleIfAvailable()
                .disabled(self.username.isEmpty || self.password.isEmpty || (self.totpRequired && self.totpToken.isEmpty))
                
                Text("or")
                
                Button(action: self.passkeySignIn) {
                    Label("Use passkey", systemImage: "person.badge.key")
                        .frame(maxWidth: .infinity)
                        
                }
                .glassProminentButtonStyleIfAvailable()
            }
            .padding()
            
            VStack(spacing: 15) {
                NavigationLink("Sign up", destination: RegistrationView())
                
                NavigationLink("Forgot password?", destination: ForgotPasswordView())
                
                SwitchServerLink()
            }
            .padding(.vertical)
        }
        .textFieldStyle(.roundedBorder)
        .padding()
        .frame(maxWidth: 500)
    }
    
    func signIn() {
        Task {
            do {
                try await self.connectionHandler.createInstance(username: self.username, password: self.password, totpToken: self.totpToken.isEmpty ? nil : self.totpToken)
            } catch {
                if case ApiError.totpRequired = error {
                    withAnimation {
                        self.totpRequired = true
                        self.isTotpFocused = true
                    }
                } else {
                    self.errorHandler.handle(error, while: "signing in")
                }
            }
        }
    }
    
    func passkeySignIn() {
        Task {
            do {
                let tokenResponse = try await self.connectionHandler.apiHandler.signInWithPasskey()
                
                do {
                    let user = try await self.connectionHandler.apiHandler.getMe()
                    
                    try self.connectionHandler.login(tokenResponse, username: user.username)
                } catch {
                    self.errorHandler.handle(error, while: "getting user info after passkey authentication")
                }
            } catch {
                self.errorHandler.handle(error, while: "signing in with passkey")
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
    .withMockEnvironment()
}
