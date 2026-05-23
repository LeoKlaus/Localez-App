//
//  ProjectStats+mokc.swift
//  Localez
//
//  Created by Leo Wehrfritz on 19.05.26.
//

import Localez_API

nonisolated extension ProjectStats {
    static let mock = ProjectStats(
        totalStrings: 42,
        languages: [
            .mockTranslated,
            .mockInProgress,
            .mockEmpty
        ]
    )
}
