//
//  MainViewModel.swift
//  iOS App
//
//  Created by Kirill Pukhov on 13.04.2022.
//

import Foundation
import RxSwift
import RxDataSources

typealias TransactionsListModel = AnimatableSectionModel<String, Transaction>

enum MainViewModelError: Error {
    case accountIsNotSet
}

struct MainViewModel {
    public var sceneCoordinator: SceneCoordinatorProtocol
    
    public let transactionService: TransactionServiceProtocol
    private let managedObjectContrextService: ManagedObjectContextServiceProtocol
    
    private let disposeBag: DisposeBag
    
    public var tableItemsSubject: BehaviorSubject<[TransactionsListModel]>
    
    init(sceneCoordinator: SceneCoordinatorProtocol) {
        self.sceneCoordinator = sceneCoordinator
        
        transactionService = TransactionService()
        managedObjectContrextService = ManagedObjectContextService.shared
        
        disposeBag = DisposeBag()
        
        tableItemsSubject = BehaviorSubject<[TransactionsListModel]>(value: [TransactionsListModel]())
        
        transactionService.currentTransactions
            .map { transactions -> [TransactionsListModel] in
                var sortedTransactions = [String : [Transaction]]()
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                
                for transaction in transactions {
                    if sortedTransactions[dateFormatter.string(from: transaction.date!)] == nil {
                        sortedTransactions[dateFormatter.string(from: transaction.date!)] = [transaction]
                    } else {
                        sortedTransactions[dateFormatter.string(from: transaction.date!)]!.append(transaction)
                    }
                }
                
                var transactionListModels = [TransactionsListModel]()
                for sortedTransaction in sortedTransactions {
                    transactionListModels.append(TransactionsListModel(model: sortedTransaction.key, items: sortedTransaction.value))
                }
                
                return transactionListModels
            }
            .subscribe(tableItemsSubject)
            .disposed(by: disposeBag)
    }
    
    @discardableResult
    public func onCreateTransaction() -> Completable {
        let subject = PublishSubject<Never>()
        
        do {
            guard let currentAccount = try transactionService.currentAccount.value() else {
                throw MainViewModelError.accountIsNotSet
            }
            
            transactionService.createTransaction(in: currentAccount)
                .subscribe(onSuccess: { transaction in
                    let transactionViewModel = TransactionViewModel(for: transaction, sceneCoordinator: sceneCoordinator)
                    
                    sceneCoordinator.transition(to: .transaction(transactionViewModel), with: .modal)
                    
                    subject.onCompleted()
                }, onFailure: {  subject.onError($0) })
                .disposed(by: disposeBag)
        } catch {
            subject.onError(error)
        }
        
        return subject.asCompletable()
    }
    
    @discardableResult
    public func onDeleteTransaction(at indexPath: IndexPath) -> Completable {
        let subject = PublishSubject<Never>()
        
        let section = (try! tableItemsSubject.value())[indexPath.section]
        let transaction = section.items[indexPath.row]
        
        transactionService.delete(transaction: transaction)
        
        managedObjectContrextService.saveContext()
            .subscribe(onCompleted: {
                subject.onCompleted()
            }, onError: { subject.onError($0) })
            .disposed(by: disposeBag)
        
        return subject.asCompletable()
    }
}
