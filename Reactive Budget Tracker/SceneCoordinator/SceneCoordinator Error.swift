//
//  SceneCoordinator Error.swift
//  Reactive Budget Tracker
//
//  Created by Kirill Pukhov on 14.05.2022.
//

import Foundation

enum SceneCoordinatroError: Error {
    case canNotPushWithoutNavigationController
    case canNotPopLastViewInNavigationController
    case canNotNavigateBack
}
