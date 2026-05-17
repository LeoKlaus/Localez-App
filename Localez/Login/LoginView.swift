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
            
            Text("Welcome to **Localez**")
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
            
            Button("Sign in", action: self.signIn)
                .glassProminentButtonStyleIfAvailable()
                .padding()
                .disabled(self.username.isEmpty || self.password.isEmpty || (self.totpRequired && self.totpToken.isEmpty))
            
            
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
}

#Preview {
    NavigationStack {
        LoginView()
    }
    .withMockEnvironment()
}
