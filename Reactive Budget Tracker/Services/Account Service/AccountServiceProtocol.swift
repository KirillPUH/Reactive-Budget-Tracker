//
//  AccountServiceProtocol.swift
//  iOS App
//
//  Created by Kirill Pukhov on 13.04.2022.
//

import Foundation
import RxSwift

protocol AccountServiceProtocol {
    
    var accounts: Observable<[Account]> { get }
    
    var selectedAccountObserver: Observable<Account?> { get }
    var selectedAccount: Account? { get }
    
    @discardableResult
    func changeAccount(to account: Account) -> Completable
    
    @discardableResult
    func createAccount() -> Single<Account>
    
    @discardableResult
    func delete(account: Account) -> Completable
}
