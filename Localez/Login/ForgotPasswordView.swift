//
//  ForgotPasswordView.swift
//  Localez
//
//  Created by Leo Wehrfritz on 17.05.26.
//

import SwiftUI
import EasyErrorHandling
import Localez_API

struct ForgotPasswordView: View {
    
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    @State private var username: String = ""
    @State private var recoveryWords: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var showPasswordWarning: Bool = false
    
    var body: some View {
        VStack {
            Text("Recover account")
                .bold()
            Text("Enter your recovery words to reset your password.")
                .foregroundStyle(.secondary)
            
            TextField("Username", text: self.$username)
                .textContentType(.username)
            
            
            VStack {
                TextField("Recovery words (space-separated)", text: self.$recoveryWords)
                Text("Enter all 12 words separated by spaces")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }.padding(.bottom)
            
            SecureField("New password", text: self.$password)
                .textContentType(.newPassword)
            
            SecureField("Confirm password", text: self.$confirmPassword)
                .textContentType(.newPassword)
                .onSubmit(self.resetPassword)
            
            if showPasswordWarning {
                Text("Passwords do not match.")
                    .foregroundStyle(.red)
            }
            
            Button("Reset password", action: self.resetPassword)
                .glassProminentButtonStyleIfAvailable()
                .padding()
                .disabled(self.username.isEmpty || self.recoveryWords.isEmpty || self.password.isEmpty || self.confirmPassword.isEmpty)
        }
        .textFieldStyle(.roundedBorder)
        .padding()
        .frame(maxWidth: 500)
    }
    
    func resetPassword() {
        guard self.password == self.confirmPassword else {
            withAnimation {
                self.showPasswordWarning = true
            }
            return
        }
        
        withAnimation {
            self.showPasswordWarning = false
        }
        
        let wordArray = self.recoveryWords.split(separator: " ").map { String($0) }
        
        Task {
            do {
                let tokenResponse = try await self.connectionHandler.apiHandler.recoverAccount(username: self.username, recoveryWords: wordArray, newPassword: self.password)
                try self.connectionHandler.login(tokenResponse, username: self.username)
            } catch {
                self.errorHandler.handle(error, while: "recovering account")
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
        .withMockEnvironment()
}
