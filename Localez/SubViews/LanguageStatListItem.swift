//
//  LanguageStatListItem.swift
//  Localez
//
//  Created by Leo Wehrfritz on 19.05.26.
//

import SwiftUI
import Localez_API
import Charts

struct LanguageStatListItem: View {
    
    let languageStats: LanguageStats
    let total: Int
    
    var translatedPercentage: Int {
        Int((Double(self.languageStats.translated) / Double(self.total) * 100).rounded())
    }
    
    var needsReviewPercentage: Int {
        Int((Double(self.languageStats.needsReview) / Double(self.total) * 100).rounded())
    }
    
    var missingPercentage: Int {
        Int((Double(self.languageStats.missing) / Double(self.total) * 100).rounded())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(self.languageStats.language)
                .bold()
            Chart {
                BarMark(
                    x: .value("Translated", self.languageStats.translated),
                    stacking: .normalized
                )
                .foregroundStyle(.green)
                .annotation(position: .overlay, alignment: .center) {
                    if self.languageStats.translated > 0 {
                        Text(self.languageStats.translated, format: .number)
                            .foregroundStyle(.white)
                            .font(.caption2)
                    }
                }
                
                BarMark(
                    x: .value("Needs Review", self.languageStats.needsReview),
                    stacking: .normalized
                )
                .foregroundStyle(.yellow)
                .annotation(position: .overlay, alignment: .center) {
                    if self.languageStats.needsReview > 0 {
                        Text(self.languageStats.needsReview, format: .number)
                            .foregroundStyle(.white)
                            .font(.caption2)
                    }
                }
                
                BarMark(
                    x: .value("Missing", self.languageStats.missing),
                    stacking: .normalized
                )
                .foregroundStyle(.gray.opacity(0.25))
                .annotation(position: .overlay, alignment: .center) {
                    if self.languageStats.missing > 0 {
                        Text(self.languageStats.missing, format: .number)
                            .foregroundStyle(.white)
                            .font(.caption2)
                    }
                }
            }
            .chartXAxis(.hidden)
            .frame(height: 15)
            .clipShape(.capsule)
            
            
            HStack {
                if self.languageStats.translated > 0 {
                    Text("\(self.translatedPercentage, format: .percent) translated")
                }
                if self.languageStats.needsReview > 0 {
                    Text("\(self.needsReviewPercentage, format: .percent) need review")
                }
                
                if self.languageStats.missing > 0 {
                    Text("\(self.missingPercentage, format: .percent) missing")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    List {
        LanguageStatListItem(
            languageStats: .mockTranslated,
            total: ProjectStats.mock.totalStrings
        )
        LanguageStatListItem(
            languageStats: .mockInProgress,
            total: ProjectStats.mock.totalStrings
        )
        LanguageStatListItem(
            languageStats: .mockEmpty,
            total: ProjectStats.mock.totalStrings
        )
    }
    .withMockEnvironment()
}
