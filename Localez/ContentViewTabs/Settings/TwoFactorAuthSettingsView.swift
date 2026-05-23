//
//  TwoFactorAuthSettingsView.swift
//  Localez
//
//  Created by Leo Wehrfritz on 18.05.26.
//

import SwiftUI
import Localez_API
import EasyErrorHandling

struct TwoFactorAuthSettingsButton: View {
    
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    @Binding var me: MeResponse
    
    @State private var setupResponse: TotpSetupResponse?
    
    @State private var showRemovalAlert: Bool = false
    @State private var removalConfirmationCode: String = ""
    
    var body: some View {
        Group {
            if me.totpEnabled {
                Button("Disable authenticator", systemImage: "xmark.shield", role: .destructive) {
                    self.showRemovalAlert = true
                }
                .foregroundStyle(.red)
            } else {
                Button("Set up authenticator", systemImage: "lock.shield", action: self.beginSetup)
            }
        }
        .sheet(item: self.$setupResponse, onDismiss: self.refreshUser) { setupResponse in
            TotpConfirmationSheet(setupResponse: setupResponse)
                .presentationDetents([.medium, .large])
        }
        .alert("Remove authenticator", isPresented: self.$showRemovalAlert) {
            TextField("Code", text: self.$removalConfirmationCode)
            Button("Remove", role: .destructive, action: self.removeAuthenticator)
                .textContentType(.oneTimeCode)
                .disabled(self.removalConfirmationCode.isEmpty)
        } message: {
            Text("Enter the current code from your authenticator app to confirm.")
        }
    }
    
    func beginSetup() {
        Task {
            do {
                self.setupResponse = try await self.connectionHandler.apiHandler.post(nil as TotpSetupResponse?)
            } catch {
                self.errorHandler.handle(error, while: "starting totp setup")
            }
        }
    }
    
    func refreshUser() {
        Task {
            do {
                let newMe: MeResponse = try await self.connectionHandler.apiHandler.get()
                withAnimation {
                    self.me = newMe
                }
            } catch {
                self.errorHandler.handle(error, while: "refreshing user")
            }
        }
    }
    
    func removeAuthenticator() {
        Task {
            do {
                _ = try await self.connectionHandler.apiHandler.sendRequest(
                    method: .POST,
                    endpoint: .disableTotp,
                    object: TotpCodeRequest(code: self.removalConfirmationCode)
                )
                self.errorHandler.showInfo("Authenticator removed!")
                self.refreshUser()
            } catch {
                self.errorHandler.handle(error, while: "refreshing user")
            }
        }
    }
}

import CoreImage.CIFilterBuiltins

enum QRCodeError: Error {
    case noOutputImage
    case noCGImage
}

struct TotpConfirmationSheet: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    let setupResponse: TotpSetupResponse
    
    @State private var qrCodeImage: Image?
    @State private var confirmationCode: String = ""
    
    var body: some View {
        VStack {
            if let qrCodeImage {
                qrCodeImage
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300)
            } else {
                Button("Show QR code", systemImage: "qrcode", action: self.generateQrCode)
                    .glassProminentButtonStyleIfAvailable()
                    .padding()
            }
            
            Text("Authenticator secret")
            HStack {
                Text(setupResponse.secret)
                    .monospaced()
                    .foregroundStyle(.secondary)
                
                Button("Copy", systemImage: "doc.on.doc", action: self.copySecret)
            }
            .padding(.bottom)
            
            VStack(spacing: 0) {
                Text("Verification code")
                TextField("000000", text: self.$confirmationCode)
                    .textContentType(.oneTimeCode)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 200)
            }
            
            HStack {
                Button(action: self.submitCode) {
                    Label("Submit", systemImage: "paperplane")
                        .frame(maxWidth: .infinity)
                }
                .glassProminentButtonStyleIfAvailable()
                .disabled(self.confirmationCode.isEmpty)
                
                Button(role: .destructive) {
                    self.dismiss()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
                .glassProminentButtonStyleIfAvailable()
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    func generateQrCode() {
        Task {
            do {
                let context = CIContext()
                let filter = CIFilter.qrCodeGenerator()
                
                filter.message = Data(self.setupResponse.uri.utf8)
                
                guard let outputImage = filter.outputImage else {
                    throw QRCodeError.noOutputImage
                }
                
                guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                    throw QRCodeError.noCGImage
                }
                
                #if canImport(UIKit)
                self.qrCodeImage = Image(uiImage: UIImage(cgImage: cgImage))
                #else
                self.qrCodeImage = Image(
                    nsImage: NSImage(
                        cgImage: cgImage,
                        size: NSSize(
                            width: cgImage.width,
                            height: cgImage.height
                        )
                    )
                )
                #endif
            } catch {
                self.errorHandler.handle(error, while: "generating QR code")
            }
        }
    }
    
    func copySecret() {
#if canImport(UIKit)
        UIPasteboard.general.string = self.setupResponse.secret
#else
        NSPasteboard.general.setString(self.setupResponse.secret, forType: .string)
#endif
        self.errorHandler.showInfo("Copied!")
    }
    
    func submitCode() {
        Task {
            do {
                _ = try await self.connectionHandler.apiHandler.sendRequest(
                    method: .POST,
                    endpoint: .verifyTotp,
                    object:
                        TotpVerifyRequest(
                            secret: self.setupResponse.secret,
                            code: self.confirmationCode
                        )
                )
                self.errorHandler.showInfo("Authenticator registered!")
                self.dismiss()
            } catch {
                self.errorHandler.handle(error, while: "confirming totp token")
            }
        }
    }
}

#Preview("Disabled") {
    NavigationStack {
        List {
            TwoFactorAuthSettingsButton(me: .constant(.mockInsecure))
        }
    }
    .withMockEnvironment()
}

#Preview("Enabled") {
    NavigationStack {
        List {
            TwoFactorAuthSettingsButton(me: .constant(.mockAdmin))
        }
    }
    .withMockEnvironment()
}

#Preview("Setup sheet") {
    List {
        TwoFactorAuthSettingsButton(me: .constant(.mockInsecure))
    }
    .sheet(isPresented: .constant(true)) {
        TotpConfirmationSheet(setupResponse: .mock)
            .presentationDetents([.medium, .large])
    }
    .withMockEnvironment()
}
