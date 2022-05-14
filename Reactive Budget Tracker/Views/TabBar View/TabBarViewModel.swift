//
//  TabBarViewModel.swift
//  iOS App
//
//  Created by Kirill Pukhov on 16.04.2022.
//

import Foundation
import RxSwift

struct TabBarViewModel {
    public var sceneCoordinator: SceneCoordinatorProtocol
    
    private let disposeBag: DisposeBag
    
    init(sceneCoordinator: SceneCoordinatorProtocol) {
        self.sceneCoordinator = sceneCoordinator
        
        self.disposeBag = DisposeBag()
    }
    
}
