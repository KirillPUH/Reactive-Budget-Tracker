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

fileprivate extension Collection where Element == Account {
    func index(of element: Element) -> Int? {
        for index in self.indices {
            if self[index] == element {
                return self.distance(from: self.startIndex, to: index) - 1
            }
        }
        return nil
    }
}

class AccountService: AccountServiceProtocol {
    
    private let managedObjectContextService: ManagedObjectContextServiceProtocol
    
    private let disposeBag: DisposeBag
    
    public lazy var accounts: Observable<[Account]> = {
        Observable<[Account]>.create { [weak self] observable in
            guard let strongSelf = self else {
                print("Memory leak!")
                return Disposables.create { }
            }
            
            self?.managedObjectContextService.context.rx.didSaveObjects()
                .startWith(Void())
                .subscribe(onNext: {
                    let fetchRequest = Account.fetchRequest()
                    let sortDesriptor = NSSortDescriptor(key: "title", ascending: true)
                    fetchRequest.sortDescriptors = [sortDesriptor]
                    
                    do {
                        let accounts = try strongSelf.managedObjectContextService.context.fetch(fetchRequest)
                        observable.onNext(accounts)
                    } catch {
                        observable.onError(AccountServiceError.accountFetchError(error))
                    }
                })
                .disposed(by: strongSelf.disposeBag)
            
            return Disposables.create { }
        }
        .share(replay: 1, scope: .forever)
    }()
    
    public lazy var selectedAccountObserver: Observable<Account?> = {
        Observable<Account?>.create { [weak self] observable in
            guard let strongSelf = self else {
                print("Memory leak!")
                return Disposables.create { }
            }
            
            UserDefaults.standard.rx.observe(String.self, "currentAccountUUID")
                .subscribe(onNext: { uuidString in
                    guard let uuidString = uuidString else {
                        observable.onNext(nil)
                        return
                    }
                    
                    let fetchRequest = Account.fetchRequest()
                    
                    do {
                        let accounts = try strongSelf.managedObjectContextService.context.fetch(fetchRequest)

                        guard let account = accounts.first(where: { $0.id!.uuidString == uuidString }) else {
                            observable.onNext(nil)
                            return
                        }

                        observable.onNext(account)
                    } catch {
                        observable.onNext(nil)
                    }
                })
                .disposed(by: strongSelf.disposeBag)
            
            return Disposables.create { }
        }
        .share(replay: 1, scope: .forever)
    }()
    
    public var selectedAccount: Account? {
        guard let uuidString = UserDefaults.standard.string(forKey: "currentAccountUUID") else {
            return nil
        }
        
        let fetchRequest = Account.fetchRequest()
        
        do {
            let accounts = try managedObjectContextService.context.fetch(fetchRequest)

            guard let account = accounts.first(where: { $0.id!.uuidString == uuidString }) else {
                return nil
            }

            return account
        } catch {
            return nil
        }
    }
    
    init() {
        managedObjectContextService = ManagedObjectContextService.shared
        
        disposeBag = DisposeBag()
    }
    
    @discardableResult
    public func changeAccount(to account: Account) -> Completable {
        UserDefaults.standard.set(account.id!.uuidString, forKey: "currentAccountUUID")
        
        return Completable.empty()
    }
    
    @discardableResult
    public func createAccount() -> Single<Account> {
        let account = Account(context: self.managedObjectContextService.context)
        
        return Single.just(account)
    }
    
    @discardableResult
    public func delete(account: Account) -> Completable {
        var accounts = [Account]()
        
        _ = self.accounts
            .take(1)
            .subscribe(onNext: {
                accounts = $0
            })
        
        guard let currentAccountIndex = accounts.index(of: account) else {
            return Completable.error(AccountServiceError.accountDidNotFound)
        }
        
        var nextAccount: Account?
        if accounts.count == 1 {
            nextAccount = nil
        } else if account == accounts.last! {
            nextAccount = accounts[currentAccountIndex - 1]
        } else {
            nextAccount = accounts[currentAccountIndex + 1]
        }
        
        UserDefaults.standard.set(nextAccount?.id?.uuidString, forKey: "currentAccountUUID")
        managedObjectContextService.context.delete(account)
        
        return Completable.empty()
    }
}
