//
//  TotpSetupResponse+identifiable.swift
//  Localez
//
//  Created by Leo Wehrfritz on 18.05.26.
//

import Localez_API

extension TotpSetupResponse: @retroactive Identifiable {
    public var id: String {
        self.uri
    }
}
