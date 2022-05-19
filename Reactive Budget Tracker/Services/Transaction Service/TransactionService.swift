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
    
    init() {
        managedObjectContextService = ManagedObjectContextService.shared
        
        disposeBag = DisposeBag()
    }
    
    public func transactions(for account: Account) -> Observable<[Transaction]> {
        let transactionsObserver = account.rx.observe(\.transactions)
        let managedObjectContextDidSaveObserver = managedObjectContextService.context.rx.didSaveObjects().startWith(Void())
        
        return Observable.zip(transactionsObserver,
                                        managedObjectContextDidSaveObserver)
            .map { transactionsSet, _ in
                return (transactionsSet?.allObjects as? [Transaction]) ?? []
            }
    }
    
    public func delete(transaction: Transaction) {
        managedObjectContextService.context.delete(transaction)
    }
    
    @discardableResult
    public func createTransaction(in account: Account) -> Single<Transaction> {
        let transaction = Transaction(context: managedObjectContextService.context)
        transaction.account = account
        transaction.currency = account.currency
        
        return Single<Transaction>.just(transaction)
    }
}
