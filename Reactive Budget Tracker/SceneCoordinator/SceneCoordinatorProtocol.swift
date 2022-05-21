//
//  SceneCoordinatorProtocol.swift
//  iOS App
//
//  Created by Kirill Pukhov on 13.04.2022.
//

import Foundation
import UIKit
import RxSwift

protocol SceneCoordinatorProtocol {
    var window: UIWindow { get set }
    var currentViewController: UIViewController! { get set }
    
    @discardableResult
    func transition(to scene: Scene, with type: SceneTransitionType) -> Completable
    
    @discardableResult
    func pop(animated: Bool) -> Completable
}
