//
//  TabBarViewController.swift
//  iOS App
//
//  Created by Kirill Pukhov on 16.04.2022.
//

import UIKit
import RxSwift

class TabBarViewController: UITabBarController, BindableProtocol {
    var viewModel: TabBarViewModel!
    
    private var disposeBag: DisposeBag!
    
    private func configureViewController(_ viewController: UIViewController) {
        if let navigationViewController = viewController as? UINavigationController,
           let viewController = navigationViewController.viewControllers.first as? MainViewController {
            let mainViewModel = MainViewModel(sceneCoordinator: self.viewModel.sceneCoordinator)
            viewController.bindViewModel(to: mainViewModel)
            
            self.viewModel.sceneCoordinator.currentViewController = viewController
        } else if let navigationViewController = viewController as? UINavigationController,
                  let viewController = navigationViewController.viewControllers.first as? AccountsListViewController {
            let accountsListViewModel = AccountsListViewModel(sceneCoordinator: self.viewModel.sceneCoordinator)
            viewController.bindViewModel(to: accountsListViewModel)
            
            self.viewModel.sceneCoordinator.currentViewController = viewController
        }
    }
    
    func bindViewModel() {
        disposeBag = DisposeBag()
        
        self.rx.didSelect
            .subscribe(onNext: { [weak self] viewController in
                guard let self = self else { return }
                
                self.configureViewController(viewController)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let mainNavigationViewController = storyboard.instantiateViewController(withIdentifier: "MainNavigationViewController") as! UINavigationController
        let mainViewController = mainNavigationViewController.viewControllers.first! as! MainViewController
        let mainViewControllerTabBarImage = UIImage(systemName: "banknote.fill")
        let mainViewControllerTabBarSelectedImage = UIImage(systemName: "banknote.fill")
        mainViewController.tabBarItem = UITabBarItem(title: "Main",
                                                     image: mainViewControllerTabBarImage,
                                                     selectedImage: mainViewControllerTabBarSelectedImage)
        
        let accountsListNavigationViewController = storyboard.instantiateViewController(withIdentifier: "AccountsListNavigationViewController") as! UINavigationController
        let accountsListViewController = accountsListNavigationViewController.viewControllers.first! as! AccountsListViewController
        let accountsListViewControllerTabBarImage = UIImage(systemName: "building.columns.fill")
        let accountsListViewControllerTabBarSelectedImage = UIImage(systemName: "building.columns.fill")
        accountsListViewController.tabBarItem = UITabBarItem(title: "Accounts",
                                                             image: accountsListViewControllerTabBarImage,
                                                             selectedImage: accountsListViewControllerTabBarSelectedImage)
        
        viewControllers = [mainNavigationViewController, accountsListNavigationViewController]
        
        configureViewController(selectedViewController!)
    }
}
