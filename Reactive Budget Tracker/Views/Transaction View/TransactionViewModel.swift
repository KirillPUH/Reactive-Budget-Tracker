//
//  TransactionViewModel.swift
//  iOS App
//
//  Created by Kirill Pukhov on 13.04.2022.
//

import Foundation
import RxSwift
import RxDataSources

typealias TransactionCellModel = SectionModel<String, TransactionTableViewCellType>

struct TransactionViewModel {
    public var sceneCoordinator: SceneCoordinatorProtocol
    
    public let managedObjectContextService: ManagedObjectContextService
    
    private let disposeBag: DisposeBag
    
    public let transaction: Transaction
    public var tableItems: Observable<[TransactionCellModel]>
    
    init(for transaction: Transaction, sceneCoordinator: SceneCoordinatorProtocol) {
        self.sceneCoordinator = sceneCoordinator
        
        managedObjectContextService = ManagedObjectContextService.shared
        
        disposeBag = DisposeBag()
        
        self.transaction = transaction
        
        tableItems = Observable.create {
            $0.onNext([TransactionCellModel(model: "Transaction",
                                            items: TransactionTableViewCellType.allCases)])
            return Disposables.create { }
        }
    }
    
    @discardableResult
    public func onDone() -> Completable {
        let subject = PublishSubject<Never>()
        
        managedObjectContextService.saveContext()
            .subscribe(onError: { subject.onError($0) })
            .disposed(by: disposeBag)
        
        sceneCoordinator.pop(animated: true)
            .subscribe(onError: { subject.onError($0) })
            .disposed(by: disposeBag)
        
        subject.onCompleted()
        
        return subject.asCompletable()
    }
    
    @discardableResult
    public func onCancel() -> Completable {
        let subject = PublishSubject<Never>()
        
        managedObjectContextService.rollbackContext()
        sceneCoordinator.pop(animated: true)
        
        subject.onCompleted()
        
        return subject.asCompletable()
    }
}
