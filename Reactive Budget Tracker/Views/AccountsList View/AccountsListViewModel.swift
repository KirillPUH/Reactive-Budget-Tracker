//
//  AccountsListViewModel.swift
//  iOS App
//
//  Created by Kirill Pukhov on 13.04.2022.
//

import Foundation
import CoreData
import RxSwift
import RxCocoa
import RxDataSources

typealias AccountsListSection = AnimatableSectionModel<String, Account>

struct AccountsListViewModel {
    public var sceneCoordinator: SceneCoordinatorProtocol
    
    private let accountService: AccountServiceProtocol
    private let managedObjectContextService: ManagedObjectContextServiceProtocol
    
    private let disposeBag: DisposeBag
    
    public var tableItemsSubject: BehaviorSubject<[AccountsListSection]>
    
    init(sceneCoordinator: SceneCoordinatorProtocol) {
        self.sceneCoordinator = sceneCoordinator
        
        accountService = AccountService()
        managedObjectContextService = ManagedObjectContextService.shared
        
        disposeBag = DisposeBag()
        
        tableItemsSubject = BehaviorSubject<[AccountsListSection]>(value: [AccountsListSection]())
        
        accountService.accounts
            .map { [AccountsListSection(model: "Accounts", items: $0)] }
            .subscribe(tableItemsSubject)
            .disposed(by: disposeBag)
    }
    
    @discardableResult
    public func onDeleteAccount(at indexPath: IndexPath) -> Completable {
        let subject = PublishSubject<Never>()
        
        let account = try! tableItemsSubject.value()[0].items[indexPath.row]
        
        accountService.delete(account: account)
        
        managedObjectContextService.saveContext()
            .subscribe(onCompleted: { subject.onCompleted() },
                       onError: { subject.onError($0) })
            .disposed(by: disposeBag)
        
        return subject.asCompletable()
    }
    
    @discardableResult
    public func onCreateAccount() -> Completable {
        let subject = PublishSubject<Never>()
        
        accountService.createAccount()
            .subscribe { account in                
                let accountViewModel = AccountViewModel(for: account, sceneCoordinator: sceneCoordinator)
                
                sceneCoordinator.transition(to: .account(accountViewModel), with: .modal)
                
                subject.onCompleted()
            } onFailure: { subject.onError($0) }
            .disposed(by: disposeBag)
        
        return subject.asCompletable()
    }
    
    @discardableResult
    public func onSelectAccount(at indexPath: IndexPath) -> Completable {
        let subject = PublishSubject<Never>()
        
        let section = try! tableItemsSubject.value()[indexPath.section]
        let account = section.items[indexPath.row]
        accountService.changeCurrentAccount(to: account)
        subject.onCompleted()
        
        return subject.asCompletable()
    }
    
    @discardableResult
    public func onMoveAccount(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> Completable {
        let subject = PublishSubject<Never>()
        
        let accounts = try! tableItemsSubject.value()[0].items
        
        let sourceIndex = sourceIndexPath.row
        let destinationIndex = destinationIndexPath.row

        accounts[sourceIndex].orderPosition = Int32(destinationIndex + 1)
        if sourceIndex > destinationIndex {
            for row in destinationIndex..<sourceIndex {
                accounts[row].orderPosition = Int32(row + 2)
            }
        } else if sourceIndex < destinationIndex {
            for row in (sourceIndex + 1)...(destinationIndex) {
                accounts[row].orderPosition = Int32(row)
            }
        }
        
        managedObjectContextService.saveContext()
            .subscribe(onCompleted: { subject.onCompleted() },
                       onError: { subject.onError($0) })
            .disposed(by: disposeBag)
        
        return subject.asCompletable()
    }
    
    public func account(for indexPath: IndexPath) -> Account {
        let section = try! tableItemsSubject.value()[indexPath.section]
        return section.items[indexPath.row]
    }
}
