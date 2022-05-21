//
//  TransactionService.swift
//  iOS App
//
//  Created by Kirill Pukhov on 13.04.2022.
//

import Foundation
import CoreData
import RxSwift

class TransactionService: TransactionServiceProtocol {
    
    private let managedObjectContextService: ManagedObjectContextServiceProtocol
    
    private let disposeBag: DisposeBag
    
    init(managedObjectContextService: ManagedObjectContextServiceProtocol) {
        self.managedObjectContextService = managedObjectContextService
        
        disposeBag = DisposeBag()
    }
    
    public func transactions(for account: Account) -> Observable<[Transaction]> {
        let transactionsObserver = account.rx.observe(\.transactions)
        let managedObjectContextDidSaveObserver = managedObjectContextService.managedObjectContext.rx
            .didSaveObjects()
            .startWith(Void())
        
        return Observable.zip(transactionsObserver,
                                        managedObjectContextDidSaveObserver)
            .map { transactionsSet, _ in
                return (transactionsSet?.allObjects as? [Transaction]) ?? []
            }
    }
    
    public func delete(transaction: Transaction) {
        let account = transaction.account
        
        account?.removeFromTransactions(transaction)
        
        managedObjectContextService.delete(transaction)
    }
    
    @discardableResult
    public func createTransaction(in account: Account) -> Transaction {
        let transaction = Transaction(context: managedObjectContextService.managedObjectContext)
        account.addToTransactions(transaction)
        
        return transaction
    }
}
