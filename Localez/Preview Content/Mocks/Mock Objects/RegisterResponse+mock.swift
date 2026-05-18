//
//  RegisterResponse+mock.swift
//  Localez
//
//  Created by Leo Wehrfritz on 18.05.26.
//

import Localez_API

nonisolated extension RegisterResponse {
    static let mock = RegisterResponse(
        accessToken: "mock-access",
        refreshToken: "mock-refresh",
        recoveryWords: [
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
        ]
    )
}
