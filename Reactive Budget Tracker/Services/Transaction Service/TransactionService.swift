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
    private let managedObjectContext: ManagedObjectContextServiceProtocol
    
    private let disposebleBag: DisposeBag
    
    lazy var currentAccount: BehaviorSubject<Account?> = {
        let currentAccountUUIDObserver = UserDefaults.standard.rx.observe(String.self, "currentAccountUUID")
            .map { _ in }
        
        let contextSavingObserver = managedObjectContext.context.rx.didSaveObjects()
        
        let subject = BehaviorSubject<Account?>(value: nil)
        
        Observable.of(currentAccountUUIDObserver, contextSavingObserver)
            .merge()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                guard let uuidString = UserDefaults.standard.string(forKey: "currentAccountUUID") else {
                    subject.onNext(nil)
                    return
                }
                
                let predicate = NSPredicate(format: "id == %@", uuidString)
                let fetchRequest = Account.fetchRequest()
                
//            ERROR: With using of predicate newly created account fetch requests returns empty array!
//            fetchRequest.predicate = predicate
                
                let account = try! self.managedObjectContext.context.fetch(fetchRequest).first(where: { $0.id!.uuidString == uuidString })
                
                // Get current account
                guard let account = try! self.managedObjectContext.context.fetch(fetchRequest).first else {
                    subject.onNext(nil)
                    return
                }
                
                subject.onNext(account)
            })
            .disposed(by: disposebleBag)
        
        return subject
    }()
    
    lazy var currentTransactions: BehaviorSubject<[Transaction]> = {
        let subject = BehaviorSubject<[Transaction]>(value: [])
        
        currentAccount.asObservable()
            .map { account in
                if let account = account {
                    let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
                    
                    let transactions = account.transactions!.sortedArray(using: [sortDescriptor]) as! [Transaction]
                    
                    return transactions
                } else {
                    return []
                }
            }
            .subscribe(subject)
            .disposed(by: disposebleBag)
        
        return subject
    }()
    
    init() {
        managedObjectContext = ManagedObjectContextService.shared
        
        disposebleBag = DisposeBag()
    }
    
    func transactions(for account: Account) -> Observable<[Transaction]> {
        let subject = PublishSubject<[Transaction]>()
        
        managedObjectContext.context.rx.didSaveObjects()
            .map {
                let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
                
                let transactions = account.transactions?.sortedArray(using: [sortDescriptor]) as! [Transaction]
                
                return transactions
            }
            .subscribe(subject)
            .disposed(by: disposebleBag)
        
        return subject.asObservable()
    }
    
    func delete(transaction: Transaction) -> Completable {
        let subject = PublishSubject<Never>()
        
        managedObjectContext.context.delete(transaction)
        
        subject.onCompleted()
        
        return subject.asCompletable()
    }
    
    func createTransaction(in account: Account) -> Single<Transaction> {
        return Single<Transaction>.create { [unowned self] single in
            let transaction = Transaction(context: self.managedObjectContext.context)
            transaction.account = account
            transaction.currency = account.currency
            
            single(.success(transaction))
            
            return Disposables.create { }
        }
    }
}
