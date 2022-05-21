//
//  MainViewModel.swift
//  iOS App
//
//  Created by Kirill Pukhov on 13.04.2022.
//

import Foundation
import CoreData
import RxSwift
import RxCocoa
import RxDataSources

typealias TransactionsListSection = AnimatableSectionModel<String, Transaction>

final class MainViewModel {
    
    private let sceneCoordinator: SceneCoordinatorProtocol
    private let managedObjectContrextService: ManagedObjectContextServiceProtocol
    private let transactionService: TransactionServiceProtocol
    private let accountService: AccountServiceProtocol
    
    // Rx
    private let disposeBag: DisposeBag
    
    // Inputs
    private(set) var createTransactionAction: PublishSubject<Void>!
    private(set) var deleteTransactionAction: PublishSubject<Transaction>!
    private(set) var selectTransactionAction: PublishSubject<Transaction>!
    
    // Outputs
    private(set) var isPlusButtonEnabled: Driver<Bool>!
    private(set) var tableItems: Observable<[TransactionsListSection]>!
    
    init(sceneCoordinator: SceneCoordinatorProtocol,
         managedObjectContextService: ManagedObjectContextServiceProtocol) {
        self.managedObjectContrextService = managedObjectContextService
        accountService = AccountService(managedObjectContextService: self.managedObjectContrextService)
        transactionService = TransactionService(managedObjectContextService: self.managedObjectContrextService)
        
        self.sceneCoordinator = sceneCoordinator
        
        disposeBag = DisposeBag()
        
        configureActions()
        configureProperties()
        configureTableItems()
    }
    
}

extension MainViewModel {
    
    private func configureActions() {
        createTransactionAction = PublishSubject<Void>()
        createTransactionAction
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { fatalError() }
                
                guard let selectedAccount = self?.accountService.selectedAccount else { return }
                
                if let transaction = self?.transactionService.createTransaction(in: selectedAccount) {
                    let viewModel = TransactionViewModel(for: transaction,
                                                         sceneCoordinator: strongSelf.sceneCoordinator,
                                                         managedObjectContextService: strongSelf.managedObjectContrextService)
                    self?.sceneCoordinator.transition(to: .transaction(viewModel), with: .modal)
                }
            })
            .disposed(by: disposeBag)
        
        deleteTransactionAction = PublishSubject<Transaction>()
        deleteTransactionAction
            .subscribe(onNext: { [weak self] transaction in
                self?.transactionService.delete(transaction: transaction)
                
                do {
                    try self?.managedObjectContrextService.saveContext()
                } catch {
                    print("\(#file) \(#function) \(error.localizedDescription)")
                    self?.managedObjectContrextService.rollbackContext()
                }
            })
            .disposed(by: disposeBag)
        
        selectTransactionAction = PublishSubject<Transaction>()
        selectTransactionAction
            .subscribe(onNext: { [weak self] transaction in
                guard let strongSelf = self else { fatalError() }
            
                let viewModel = TransactionViewModel(for: transaction,
                                                     sceneCoordinator: strongSelf.sceneCoordinator,
                                                     managedObjectContextService: strongSelf.managedObjectContrextService)
                self?.sceneCoordinator.transition(to: .transaction(viewModel), with: .modal)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureProperties() {
        isPlusButtonEnabled = accountService.accountsObserver
            .map { $0.count != 0 }
            .asDriver(onErrorJustReturn: false)
    }
    
    private func configureTableItems() {
        tableItems = Observable<[TransactionsListSection]>.create { [weak self] observable in
            guard let strongSelf = self else { fatalError() }
            
            self?.accountService.selectedAccountObserver
                .subscribe(onNext: { [weak self] account in
                    guard let account = account else {
                        observable.onNext([])
                        return
                    }
                    
                    self?.transactionService.transactions(for: account)
                        .subscribe(onNext: { transactions in
                            let sortedTransactions = transactions.sortedByDate()
                            let transactionListSections = sortedTransactions.map { sectionTitle, transactions in
                                TransactionsListSection(model: sectionTitle, items: transactions)
                            }
                            
                            observable.onNext(transactionListSections)
                        })
                        .disposed(by: strongSelf.disposeBag)
                })
                .disposed(by: strongSelf.disposeBag)
            
            return Disposables.create { }
        }
    }
        
}

fileprivate extension Collection where Element == Transaction {
    
    func sortedByDate() -> [(String, [Transaction])] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM"
        
        var sortedTransactions = [(sectionTitle: String, transactions: [Transaction])]()
        
        var lastDateString = ""
        for transaction in self {
            let dateString = dateFormatter.string(from: transaction.date!)
            
            if lastDateString != dateString {
                lastDateString = dateString
                sortedTransactions.append((dateString, [transaction]))
            } else {
                sortedTransactions[sortedTransactions.count - 1].transactions.append(transaction)
            }
        }
        
        return sortedTransactions
    }
    
}
