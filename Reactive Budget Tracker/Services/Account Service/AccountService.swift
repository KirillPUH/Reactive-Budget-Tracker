//
//  AccountService.swift
//  iOS App
//
//  Created by Kirill Pukhov on 13.04.2022.
//

import Foundation
import UIKit
import CoreData
import RxSwift

enum AccountServiceError: Error {
    case accountDidNotFound
    case accountFetchError(Error)
    case currentAccountUUIDDoesNotSet
}

class AccountService: AccountServiceProtocol {
    private let managedObjectContext: ManagedObjectContextServiceProtocol
    
    private let disposeBag: DisposeBag
    
    var accounts: BehaviorSubject<[Account]>
    
    init() {
        self.managedObjectContext = ManagedObjectContextService.shared
        
        self.disposeBag = DisposeBag()
        
        accounts = BehaviorSubject<[Account]>(value: [Account]())
            
        managedObjectContext.context.rx.didSaveObjects()
            .startWith(Void())
            .map { [weak self] in
                guard let self = self else { return [Account]() }
                
                do {
                    return try self.fetchAccounts()
                } catch {
                    throw error
                }
            }
            .subscribe(accounts)
            .disposed(by: disposeBag)
    }
    
    private func fetchAccounts() throws -> [Account] {
        let fetchRequest = Account.fetchRequest()
        let sortDesriptor = NSSortDescriptor(key: "orderPosition", ascending: true)
        fetchRequest.sortDescriptors = [sortDesriptor]
        
        do {
            return try managedObjectContext.context.fetch(fetchRequest)
        } catch {
            throw error
        }
    }
    
    @discardableResult
    public func changeCurrentAccount(to account: Account) -> Completable {
        let subject = PublishSubject<Never>()
        
        UserDefaults.standard.set(account.id!.uuidString, forKey: "currentAccountUUID")
            
        return subject.asCompletable()
    }
    
    @discardableResult
    public func createAccount() -> Single<Account> {
        Observable<Account>.create { [unowned self] observer in
            let account = Account(context: self.managedObjectContext.context)
            account.orderPosition = try! Int32(accounts.value().count + 1)
            
            observer.onNext(account)
            
            return Disposables.create { }
        }
        .take(1)
        .asSingle()
    }
    
    @discardableResult
    public func update(account: Account, title: String?) -> Completable {
        let subject = PublishSubject<Void>()
        
        if let title = title {
            account.title = title
        }
        
        subject.onCompleted()
        
        return subject.asObservable()
            .take(1)
            .ignoreElements()
            .asCompletable()
    }
    
    @discardableResult
    public func delete(account: Account) -> Completable {
        let subject = PublishSubject<Never>()
        
        let accounts = try! accounts.value()
        for index in (Int(account.orderPosition)..<accounts.count) {
            accounts[index].orderPosition -= 1
        }
        
        if accounts.count == 1 {
            UserDefaults.standard.set(nil, forKey: "currentAccountUUID")
        } else if account == accounts.last! {
            UserDefaults.standard.set(accounts[Int(account.orderPosition) - 2].id!.uuidString, forKey: "currentAccountUUID")
        } else {
            UserDefaults.standard.set(accounts[Int(account.orderPosition)].id!.uuidString, forKey: "currentAccountUUID")
        }
        
        managedObjectContext.context.delete(account)
        
        subject.onCompleted()
        
        return subject.asCompletable()
    }
}
