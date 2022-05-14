//
//  AccountServiceProtocol.swift
//  iOS App
//
//  Created by Kirill Pukhov on 13.04.2022.
//

import Foundation
import RxSwift

protocol AccountServiceProtocol {
    var accounts: BehaviorSubject<[Account]> { get }
    
    func createAccount() -> Single<Account>
    
    @discardableResult
    func changeCurrentAccount(to account: Account) -> Completable
    
    @discardableResult
    func update(account: Account, title: String?) -> Completable
    
    @discardableResult
    func delete(account: Account) -> Completable
}
