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
    
    private(set) var accountsObserver: Observable<[Account]>!
    public var accounts: [Account] {
        let fetchRequest = Account.fetchRequest()
        
        return (try? managedObjectContextService.fetch(fetchRequest)) ?? []
    }
    
    private(set) var selectedAccountObserver: Observable<Account?>!
    public var selectedAccount: Account? {
        guard let uuidString = UserDefaults.standard.string(forKey: "currentAccountUUID") else {
            return nil
        }
        
        return accounts.first(where: { $0.id!.uuidString == uuidString })
    }
    
    init(managedObjectContextService: ManagedObjectContextServiceProtocol) {
        self.managedObjectContextService = managedObjectContextService
        
        disposeBag = DisposeBag()
        
        configureProperties()
    }
    
    public func changeAccount(to account: Account) {
        UserDefaults.standard.set(account.id!.uuidString, forKey: "currentAccountUUID")
    }
    
    @discardableResult
    public func createAccount() -> Account {
        return Account(context: managedObjectContextService.managedObjectContext)
    }
    
    public func delete(account: Account) throws {
        guard let currentAccountIndex = accounts.index(of: account) else {
            throw AccountServiceError.accountDidNotFound
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
        managedObjectContextService.delete(account)
    }
    
}

extension AccountService {
    
    private func configureProperties() {
        accountsObserver = Observable<[Account]>.create { [weak self] observable in
            guard let strongSelf = self else { fatalError() }
            
            self?.managedObjectContextService.managedObjectContext.rx
                .didSaveObjects()
                .startWith(Void())
                .subscribe(onNext: {
                    let fetchRequest = Account.fetchRequest()
                    let sortDesriptor = NSSortDescriptor(key: "title", ascending: true)
                    fetchRequest.sortDescriptors = [sortDesriptor]
                    
                    do {
                        let accounts = try strongSelf.managedObjectContextService.fetch(fetchRequest)
                        observable.onNext(accounts)
                    } catch {
                        observable.onError(AccountServiceError.accountFetchError(error))
                    }
                })
                .disposed(by: strongSelf.disposeBag)
            
            return Disposables.create { }
        }
        
        selectedAccountObserver = UserDefaults.standard.rx.observe(String.self, "currentAccountUUID")
            .map { [weak self] _ in
                return self?.selectedAccount
            }
    }
    
}
