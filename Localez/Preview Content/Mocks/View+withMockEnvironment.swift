//
//  View+withMockEnvironment.swift
//  Localez
//
//  Created by Leo Wehrfritz on 17.05.26.
//

import SwiftUI
import EasyErrorHandling


struct WithMockEnvironmentViewModifier: ViewModifier {
    
    @State private var toastToShow: ErrorToast?
    
    func body(content: Content) -> some View {
        content
            .withErrorHandling(onTap: { self.toastToShow = $0 })
            .environment(ConnectionHandler.mock)
            .environment(NavigationHandler.shared)
            .sheet(item: self.$toastToShow) { toast in
                ErrorInfoSheet(toast: toast)
            }
    }
}

extension View {
    @ViewBuilder func withMockEnvironment() -> some View {
        self
            .modifier(WithMockEnvironmentViewModifier())
    }
}
