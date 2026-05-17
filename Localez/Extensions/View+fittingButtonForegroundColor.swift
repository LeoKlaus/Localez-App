//
//  View+fittingButtonForegroundColor.swift
//  Localez
//
//  Created by Leo Wehrfritz on 17.05.26.
//

import SwiftUI

struct AdaptiveForegroundColorModifier: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.isEnabled) var isEnabled
    
    private var matchingColor: Color {
        if self.colorScheme == .dark {
            if self.isEnabled {
                return .black
            } else {
                return .white
            }
        } else {
            if self.isEnabled {
                return .white
            } else {
                return .black
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(self.matchingColor)
    }
}

extension View {
    @ViewBuilder func fittingForegroundColor() -> some View {
        self
            .modifier(AdaptiveForegroundColorModifier())
    }
}
