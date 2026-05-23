//
//  NavigationHandler.swift
//  Localez
//
//  Created by Leo Wehrfritz on 18.05.26.
//

import Localez_API
import SwiftUI

enum ContentViewTab {
    case strings
    case projects
    case settings
}

@Observable
class NavigationHandler {
    static let shared = NavigationHandler()
    
    private init() { }
    
    var currentTab: ContentViewTab = .projects
    
    var projectListPath: NavigationPath = .init()
}
