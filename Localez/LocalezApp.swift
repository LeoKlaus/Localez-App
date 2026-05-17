//
//  LocalezApp.swift
//  Localez
//
//  Created by Leo Wehrfritz on 17.05.26.
//

import SwiftUI
import EasyErrorHandling
import Localez_API

@main
struct LocalezApp: App {
    
    @State private var connectionHandler: ConnectionHandler = .init()
    
    @State private var tappedErrorToast: ErrorToast? = nil
    
    var body: some Scene {
        WindowGroup {
            Group {
                if connectionHandler.isLoggedIn {
                    ContentView()
                } else {
                    NavigationStack {
                        LoginView()
                    }
                }
            }
            .environment(self.connectionHandler)
            .withErrorHandling(onTap: { self.tappedErrorToast = $0 })
            .sheet(item: self.$tappedErrorToast) { toast in
                ErrorInfoSheet(toast: toast)
            }
        }
    }
}
