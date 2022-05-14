//
//  AccountViewModel.swift
//  iOS App
//
//  Created by Kirill Pukhov on 13.04.2022.
//

import Foundation
import CoreData
import RxSwift
import RxDataSources

typealias AccountCellModel = SectionModel<String, AccountTableViewCellType>

enum AccountTableViewCellType: CaseIterable {
    case title
}

extension AccountTableViewCellType {
    var identifier: String {
        switch self {
        case .title:
            return TextFieldAccountTableViewCell.identifier
        }
    }
}

enum AccountViewModelError: Error {
    case savingContextError(Error)
}

struct AccountViewModel {
    public let sceneCoordinator: SceneCoordinatorProtocol
    
    private let accountService: AccountServiceProtocol
    private let managedObjectContextService: ManagedObjectContextServiceProtocol
    
    public var account: Account
    
    private let disposeBag: DisposeBag
    
    public var tableItems: Observable<[AccountCellModel]>
    
    init(for account: Account, sceneCoordinator: SceneCoordinatorProtocol) {
        self.sceneCoordinator = sceneCoordinator
        accountService = AccountService()
        managedObjectContextService = ManagedObjectContextService.shared
        
        self.account = account
        
        disposeBag = DisposeBag()
        
        tableItems = Observable.create {
            $0.onNext([AccountCellModel(model: "Cells",
                                        items: AccountTableViewCellType.allCases)])
            return Disposables.create { }
        }
    }
    
    @discardableResult
    public func onDone() -> Completable {
        let subject = PublishSubject<Never>()
        
        managedObjectContextService.saveContext()
            .subscribe(onError: { subject.onError($0) })
            .disposed(by: disposeBag)
        
        accountService.changeCurrentAccount(to: account)
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
            .subscribe(onError: { subject.onError($0) })
            .disposed(by: disposeBag)
        
        sceneCoordinator.pop(animated: true)
            .subscribe(onError: { subject.onError($0) })
            .disposed(by: disposeBag)
        
        subject.onCompleted()
        
        return subject.asCompletable()
    }
}
