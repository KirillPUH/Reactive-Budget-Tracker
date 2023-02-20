import Foundation

enum SceneCoordinatroError: Error {
    case canNotPushWithoutNavigationController
    case canNotPopLastViewInNavigationController
    case canNotNavigateBack
}
