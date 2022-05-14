//
//  SceneCoordinator.swift
//  iOS App
//
//  Created by Kirill Pukhov on 13.04.2022.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class SceneCoordinator: SceneCoordinatorProtocol {
    var window: UIWindow
    
    var currentViewController: UIViewController!
    
    init(window: UIWindow) {
        self.window = window
    }
    
    private static func actualViewController(for viewController: UIViewController) -> UIViewController {
        if let tabBarController = viewController as? UITabBarController {
            if let navigationController = tabBarController.selectedViewController as? UINavigationController {
                return navigationController.viewControllers.first!
            } else {
                return tabBarController.selectedViewController!
            }
        } else if let navigationController = viewController as? UINavigationController {
            return navigationController.viewControllers.first!
        } else {
            return viewController
        }
    }
    
    @discardableResult
    func transition(to scene: Scene, with type: SceneTransitionType) -> Completable {
        let subject = PublishSubject<Void>()
        do {
            let viewController = try scene.viewController()
            
            switch type {
            case .root:
                window.rootViewController = viewController
                currentViewController = Self.actualViewController(for: viewController)
                subject.onCompleted()
            case .push:
                guard let navigationController = currentViewController.navigationController else {
                    throw SceneCoordinatroError.canNotPushWithoutNavigationController
                }
                
                _ = navigationController.rx.delegate
                    .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                    .map { _ in }
                    .bind(to: subject)
                
                navigationController.pushViewController(viewController, animated: true)
                
                currentViewController = Self.actualViewController(for: viewController)
            case .modal:
                viewController.modalPresentationStyle = .fullScreen
                
                currentViewController.present(viewController, animated: true) {
                    subject.onCompleted()
                }
                
                currentViewController = Self.actualViewController(for: viewController)
            }
        } catch {
            subject.onError(error)
        }
        
        return subject.asObservable()
            .take(1)
            .ignoreElements()
            .asCompletable()
    }
    
    @discardableResult
    func pop(animated: Bool) -> Completable {
       let subject = PublishSubject<Void>()
        
        if let presenter = currentViewController.presentingViewController {
            currentViewController.dismiss(animated: animated) {
                self.currentViewController = Self.actualViewController(for: presenter)
                
                subject.onCompleted()
            }
        } else if let navigationController = currentViewController.navigationController {
            _ = navigationController.rx.delegate
                .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                .map { _ in }
                .bind(to: subject)
            
            if navigationController.popViewController(animated: animated) == nil {
                subject.onError(SceneCoordinatroError.canNotPopLastViewInNavigationController)
            } else {
                currentViewController = Self.actualViewController(for: navigationController.viewControllers.last!)
            }
        } else {
            subject.onError(SceneCoordinatroError.canNotNavigateBack)
        }
        
        return subject.asObserver()
            .take(1)
            .ignoreElements()
            .asCompletable()
    }
}
