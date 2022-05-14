//
//  Scene.swift
//  iOS App
//
//  Created by Kirill Pukhov on 13.04.2022.
//

import Foundation
import UIKit

enum Scene {
    case tabBarController(TabBarViewModel)
    case main(MainViewModel)
    case transaction(TransactionViewModel)
    case account(AccountViewModel)
    case accountsList(AccountsListViewModel)
}

extension Scene {
    func viewController() throws -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch self {
        case .tabBarController(let viewModel):
            if let tbvc = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController {
                tbvc.bindViewModel(to: viewModel)
                return tbvc
            }
            
            throw SceneError.viewControllerDidNotFound
        case .main(let viewModel):
            if let nc = storyboard.instantiateViewController(withIdentifier: "MainNavigationViewController") as? UINavigationController,
               let vc = nc.viewControllers.first as? MainViewController {
                vc.bindViewModel(to: viewModel)
                return nc
            }
            
            throw SceneError.viewControllerDidNotFound
        case .transaction(let viewModel):
            if let nc = storyboard.instantiateViewController(withIdentifier: "TransactionNavigationViewController") as? UINavigationController,
               let vc = nc.viewControllers.first as? TransactionViewController {
                vc.bindViewModel(to: viewModel)
                return nc
            }
            
            throw SceneError.viewControllerDidNotFound
        case .accountsList(let viewModel):
            if let nc = storyboard.instantiateViewController(withIdentifier: "AccountsListNavigationViewController") as? UINavigationController,
               let vc = nc.viewControllers.first! as? AccountsListViewController {
                vc.bindViewModel(to: viewModel)
                return nc
            }
            
            throw SceneError.viewControllerDidNotFound
        case .account(let viewModel):
            if let nc = storyboard.instantiateViewController(withIdentifier: "AccountNavigationViewController") as? UINavigationController,
               let vc = nc.viewControllers.first as? AccountViewController {
                vc.bindViewModel(to: viewModel)
                return nc
            }
            
            throw SceneError.viewControllerDidNotFound
        }
    }
}
