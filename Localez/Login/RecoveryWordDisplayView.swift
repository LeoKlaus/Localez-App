//
//  SafeWordDisplayView.swift
//  Localez
//
//  Created by Leo Wehrfritz on 17.05.26.
//

import SwiftUI

struct RecoveryWordDisplayView: View {
    
    @Environment(\.dismiss) var dismiss
    
    let words: [String]
    
    var columns: [GridItem] {
        [
            GridItem(.flexible(minimum: 80, maximum: 120)),
            GridItem(.flexible(minimum: 80, maximum: 120)),
            GridItem(.flexible(minimum: 80, maximum: 120))
        ]
    }
    
    @State private var showConfirmation: Bool = false
    
    var body: some View {
        VStack {
            Text("Save your recovery words")
                .bold()
            
            Text("Store these 12 words somewhere safe. They are the only way to recover your account if you lose your password. They will not be shown again.")
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: self.columns) {
                ForEach(self.words.indices, id: \.self) { index in
                    HStack(spacing: 0) {
                        Text("\(index + 1). ")
                            .foregroundStyle(.secondary)
                        Text(self.words[index])
                            .monospaced()
                        Spacer()
                    }
                }
            }
            
            Button("Copy to clipboard", systemImage: "doc.on.doc") {
                UIPasteboard.general.string = self.words.joined(separator: " ")
            }
            .padding()
            .glassProminentButtonStyleIfAvailable()
            
            Button("Done") {
                self.showConfirmation = true
            }
        }
        .alert("Have you saved your recovery words?", isPresented: self.$showConfirmation) {
            Button("Yes") {
                self.dismiss()
            }
            Button("No") { }
        } message: {
            Text("You won't be able to recover your account without these.")
        }
        .frame(maxWidth: 500)
        .padding()
    }
}

#Preview {
    RecoveryWordDisplayView(words: [
        "bandicoy",
        "gospelly",
        "subrule",
        "sovranty",
        "entasis",
        "pimelite",
        "cobbler",
        "omani",
        "salwey",
        "owling",
        "mutely",
        "reggie"
    ])
}
