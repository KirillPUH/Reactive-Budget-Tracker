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

class AccountsListViewModel {
    
    private let sceneCoordinator: SceneCoordinatorProtocol
    private let managedObjectContextService: ManagedObjectContextServiceProtocol
    private let accountService: AccountServiceProtocol
    
    // Rx
    private let disposeBag: DisposeBag
    
    // Inputs
    private(set) var editButtonAction: PublishSubject<Void>!
    private(set) var createAccountAction: PublishSubject<Void>!
    private(set) var deleteAccountAciton: PublishSubject<Account>!
    private(set) var selectAccountAction: PublishSubject<Account>!
    
    // Outputs
    private(set) var isEditButtonEnabled: Driver<Bool>!
    private(set) var isPlusButtonEnabled: Driver<Bool>!
    private(set) var isTableViewEditing: Driver<Bool>!
    private(set) var tableItems: Observable<[AccountsListSection]>!
    
    private var isEditing: BehaviorSubject<Bool>!
    
    init(sceneCoordinator: SceneCoordinatorProtocol) {
        self.sceneCoordinator = sceneCoordinator
        
        accountService = AccountService()
        managedObjectContextService = ManagedObjectContextService.shared
        
        disposeBag = DisposeBag()
        
        isEditing = BehaviorSubject<Bool>(value: false)
        
        configureTableItems()
        configureProperties()
        configureActions()
    }
    
}

extension AccountsListViewModel {
    
    private func configureActions() {
        editButtonAction = PublishSubject<Void>()
        editButtonAction
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { fatalError() }
                
                do {
                    let currentState = try strongSelf.isEditing.value()
                    self?.isEditing.onNext(!currentState)
                } catch {
                    self?.isEditing.onNext(false)
                }
            })
            .disposed(by: disposeBag)
        
        createAccountAction = PublishSubject<Void>()
        createAccountAction
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { fatalError() }
                
                self?.accountService.createAccount()
                    .subscribe(onSuccess: { account in
                        let viewModel = AccountViewModel(for: account,
                                                                sceneCoordinator: strongSelf.sceneCoordinator)
                        self?.sceneCoordinator.transition(to: .account(viewModel), with: .modal)
                    })
                    .disposed(by: strongSelf.disposeBag)
            })
            .disposed(by: disposeBag)
        
        deleteAccountAciton = PublishSubject<Account>()
        deleteAccountAciton
            .subscribe(onNext: { [weak self] account in
                self?.accountService.delete(account: account)
                
                do {
                    try self?.managedObjectContextService.saveContext()
                } catch {
                    print("\(#file) \(#function) \(error.localizedDescription)")
                    self?.managedObjectContextService.rollbackContext()
                }
            })
            .disposed(by: disposeBag)
        
        selectAccountAction = PublishSubject<Account>()
        selectAccountAction
            .subscribe(onNext: { [weak self] account in
                guard let strongSelf = self else { fatalError() }
                
                let viewModel = AccountViewModel(for: account,
                                                 sceneCoordinator: strongSelf.sceneCoordinator)
                self?.sceneCoordinator.transition(to: .account(viewModel), with: .modal
                )
            })
            .disposed(by: disposeBag)
    }
    
    private func configureProperties() {
        isEditButtonEnabled = tableItems
            .asDriver(onErrorJustReturn: [])
            .map { !$0[0].items.isEmpty }
        
        isPlusButtonEnabled = isEditing
            .map { !$0 }
            .asDriver(onErrorJustReturn: false)
        
        isTableViewEditing = isEditing
            .asDriver(onErrorJustReturn: false)
    }
    
    private func configureTableItems() {
        tableItems = accountService.accounts
            .map { [AccountsListSection(model: "Accounts", items: $0)] }
    }
    
}
