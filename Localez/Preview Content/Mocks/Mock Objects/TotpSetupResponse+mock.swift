//
//  TotpSetupResponse+mock.swift
//  Localez
//
//  Created by Leo Wehrfritz on 18.05.26.
//

import Localez_API
import Foundation

nonisolated extension TotpSetupResponse {
    static let mock = TotpSetupResponse(
        secret: "AIPOZYCRMGOXU...P475R6",
        uri: "otpauth://totp/Localez:leo?secret=AIPOZYCRMGOXU...P475R6&issuer=Localez"
    )
}
