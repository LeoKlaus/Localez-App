//
//  View+glassProminentButtonStyleIfAvailable.swift
//  Paperparrot
//
//  Created by Leo Wehrfritz on 25.04.26.
//

import SwiftUI

extension View {
    
    /// Adds the `.glassProminent` button style to the view if available.
    /// - Returns: The original `View` with the `.glassProminent` button style, if applicable, else with the original `View` with the `.borderedProminent` button style.
    @ViewBuilder func glassProminentButtonStyleIfAvailable() -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            self
                .buttonStyle(.glassProminent)
                .fittingForegroundColor()
        } else {
            self
                .buttonStyle(.borderedProminent)
                .fittingForegroundColor()
        }
    }
}
