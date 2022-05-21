//
//  TabBarViewModel.swift
//  iOS App
//
//  Created by Kirill Pukhov on 16.04.2022.
//

import Foundation
import RxSwift

class TabBarViewModel {
    
    public var sceneCoordinator: SceneCoordinatorProtocol
    private(set) var managedObjectContextService: ManagedObjectContextServiceProtocol
    
    private let disposeBag: DisposeBag
    
    init(sceneCoordinator: SceneCoordinatorProtocol, managedObjectContextService: ManagedObjectContextServiceProtocol) {
        self.sceneCoordinator = sceneCoordinator
        self.managedObjectContextService = managedObjectContextService
        
        self.disposeBag = DisposeBag()
    }
    
}
