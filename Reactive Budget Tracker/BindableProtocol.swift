//
//  BindableProtocol.swift
//  iOS App
//
//  Created by Kirill Pukhov on 13.04.2022.
//

import Foundation
import UIKit

protocol BindableProtocol: AnyObject {
    associatedtype ViewModelType
    
    var viewModel: ViewModelType! { get set }
    
    func bindViewModel()
}

extension BindableProtocol where Self: UIViewController {
    func bindViewModel(to viewModel: ViewModelType) {
        self.viewModel = viewModel
        loadViewIfNeeded()
        bindViewModel()
    }
}
