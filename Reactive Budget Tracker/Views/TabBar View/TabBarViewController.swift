//
//  TabBarViewController.swift
//  iOS App
//
//  Created by Kirill Pukhov on 16.04.2022.
//

import UIKit
import RxSwift

class TabBarViewController: UITabBarController, BindableProtocol {
    internal var viewModel: TabBarViewModel!
    
    private var disposeBag: DisposeBag!
    
    func bindViewModel() {
        disposeBag = DisposeBag()
        
        self.rx.didSelect
            .subscribe(onNext: { [weak self] viewController in
                self?.configureViewController(viewController)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
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
    
}

extension TabBarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MyTransition(viewControllers: viewControllers)
    }
    
}

class MyTransition: NSObject, UIViewControllerAnimatedTransitioning {

    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.25

    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromView = fromVC.view,
            let fromIndex = getIndex(forViewController: fromVC),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let toView = toVC.view,
            let toIndex = getIndex(forViewController: toVC)
            else {
                transitionContext.completeTransition(false)
                return
        }

        let frame = transitionContext.initialFrame(for: fromVC)
        var fromFrameEnd = frame
        var toFrameStart = frame
        fromFrameEnd.origin.x = toIndex > fromIndex ? frame.origin.x - frame.width : frame.origin.x + frame.width
        toFrameStart.origin.x = toIndex > fromIndex ? frame.origin.x + frame.width : frame.origin.x - frame.width
        toView.frame = toFrameStart

        DispatchQueue.main.async {
            transitionContext.containerView.addSubview(toView)
            UIView.animate(withDuration: self.transitionDuration, animations: {
                fromView.frame = fromFrameEnd
                toView.frame = frame
            }, completion: {success in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(success)
            })
        }
    }

    func getIndex(forViewController vc: UIViewController) -> Int? {
        guard let vcs = self.viewControllers else { return nil }
        for (index, thisVC) in vcs.enumerated() {
            if thisVC == vc { return index }
        }
        return nil
    }
}
