//
//  ErrorInfoSheet.swift
//  Localez
//
//  Created by Leo Wehrfritz on 17.05.26.
//

import SwiftUI
import EasyErrorHandling

struct ErrorInfoSheet: View {
    
    let toast: ErrorToast
    
    var body: some View {
        List {
            ContentUnavailableView("Oh no :(", systemImage: "pc")
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    return 0
                }
            
            VStack(alignment: .leading) {
                Text("Localez ran into the following error while \(self.toast.performedTask):")
                Text(self.toast.errorDescription)
                    .foregroundStyle(.red)
            }
            
            if let rawError = toast.rawError {
                Section("Details") {
                    Text(String(describing: rawError))
                }
            }
        }
    }
}

#Preview {
    ErrorInfoSheet(toast: ErrorToast(error: ConnectedInstanceError.couldntAccessUserdefaults, performedTask: "loading something"))
}
