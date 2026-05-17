//
//  SwitchServerView.swift
//  Localez
//
//  Created by Leo Wehrfritz on 17.05.26.
//

import SwiftUI
import EasyErrorHandling
import Localez_API

struct SwitchServerView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    @State private var serverProtocol: String = "https://"
    @State private var newUrlStr: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Connect to a different server")
                .bold()
            Text("Localez can be hosted by other developers. If you use Localez under a domain that's not `translate.wehrfritz.me`, you can enter the URL below to connect to the server.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            HStack {
                Picker("Protocol", selection: self.$serverProtocol) {
                    Text("https://").tag("https://")
                    Text("http://").tag("http://")
                }
                
                TextField("Localez URL", text: self.$newUrlStr)
                    .textInputAutocapitalization(.never)
                    .textContentType(.URL)
                    .keyboardType(.URL)
            }
            
            if self.serverProtocol == "http://" {
                Text("Unencrypted connections are only supported to local servers!")
                    .foregroundStyle(.red)
            }
            
            Button("Connect", action: self.connect)
                .glassProminentButtonStyleIfAvailable()
                .padding()
                .disabled(self.newUrlStr.isEmpty)
            
            if self.connectionHandler.apiHandler.baseURL.host() != "translate.wehrfritz.me" {
                Button("Reset") {
                    guard let defaultURL = URL(string: "https://translate.wehrfritz.me") else {
                        self.errorHandler.handle("Couldn't reset URL", while: "resetting to default server")
                        return
                    }
                    self.connectionHandler.switchServerBaseURL(defaultURL)
                    self.dismiss()
                }
            }
            
            if let ghURL = URL(string: "https://github.com/leoklaus/Localez") {
                Link("Learn more about self-hosting Localez", destination: ghURL)
                    .padding(.top)
            }
        }
        .textFieldStyle(.roundedBorder)
        .padding()
        .frame(maxWidth: 500)
    }
    
    func connect() {
        guard let newServerURL = URL(string: self.serverProtocol + self.newUrlStr) else {
            self.errorHandler.handle("Entered URL is not valid", while: "switching server")
            return
        }
        
        self.connectionHandler.switchServerBaseURL(newServerURL)
        self.errorHandler.showInfo("Server switched!")
        self.dismiss()
    }
}

#Preview {
    SwitchServerView()
        .withMockEnvironment()
}
