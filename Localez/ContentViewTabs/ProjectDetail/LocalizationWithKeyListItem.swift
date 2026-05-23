//
//  LocalizationWithKeyListItem.swift
//  Localez
//
//  Created by Leo Wehrfritz on 19.05.26.
//

import SwiftUI
import Localez_API
import EasyErrorHandling

extension VariationKeyType {
    var systemImage: String {
        switch self {
        case .deviceAppletv:
            "appletv"
        case .deviceApplevision:
            "vision.pro"
        case .deviceApplewatch:
            "applewatch"
        case .deviceiPad:
            "ipad"
        case .deviceiPhone:
            "iphone"
        case .deviceiPod:
            "ipod.touch"
        case .deviceMac:
            "macbook"
        case .pluralOne:
            "1.circle"
        case .pluralZero:
            "0.circle"
        case .other:
            "plus.circle"
        }
    }
}

extension LocalizationState {
    var backgroundColor: Color {
        switch self {
        case .new:
                .gray.mix(with: .white, by: 0.4)
        case .needsReview:
                .yellow
        case .translated:
                .green
        }
    }
    
    var pill: some View {
        Group {
            switch self {
            case .new:
                Text("New")
            case .needsReview:
                Text("Needs Review")
            case .translated:
                Text("Translated")
            }
        }
        .foregroundStyle(self.backgroundColor.mix(with: .black, by: 0.6))
        .font(.caption)
        .padding(.horizontal)
        .background(self.backgroundColor)
        .clipShape(.capsule)
    }
}

struct LocalizationWithKeyListItem: View {
    
    @Binding var string: LocalizationWithKeyResponse
    
    @Environment(ConnectionHandler.self) var connectionHandler
    @EnvironmentObject var errorHandler: ErrorHandler
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(string.key)
                    .monospaced()
                    .font(.caption)
                Spacer()
                self.string.state.pill
            }
            if let sourceValue = string.sourceValue {
                Text("Source: \(sourceValue)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            if let comment = string.comment {
                Text("Comment: \(comment)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Group {
                if self.string.state == .new || self.connectionHandler.currentInstance?.userId == self.string.valueSetBy {
                    TextField(
                        "Translation",
                        text: Binding(
                            get: {
                                self.string.value ?? ""
                            },
                            set: { newValue in
                                self.string.value = newValue
                            }
                        )
                    )
                    .multilineTextAlignment(.leading)
                } else {
                    Menu {
                        Button("Suggest alternative translation", systemImage: "translate") { }
                    } label: {
                        Text(self.string.value ?? "")
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .padding(.vertical, 3)
            
            if let variationKey = self.string.variationKey {
                HStack {
                    if case .plural = self.string.variationType {
                        Text("Plural:")
                    } else if case .device = self.string.variationType {
                        Text("Device:")
                    }
                    Image(systemName: variationKey.systemImage)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    @Previewable @State var strings: [LocalizationWithKeyResponse] = [
        .mock,
        .mockNeedsReview,
        .mockTranslated,
        .mockDeviceVariation,
        .mockPluralVariation
    ]
    
    List($strings) { $string in
        LocalizationWithKeyListItem(string: $string)
            .withMockEnvironment()
    }
}
