//
//  AccountServiceProtocol.swift
//  iOS App
//
//  Created by Kirill Pukhov on 13.04.2022.
//

import Foundation
import RxSwift

protocol AccountServiceProtocol {
    
    var accountsObserver: Observable<[Account]>! { get }
    var accounts: [Account] { get }
    
    var selectedAccountObserver: Observable<Account?>! { get }
    var selectedAccount: Account? { get }
    
    @discardableResult
    func createAccount() -> Account
    
    func changeAccount(to account: Account)

    func delete(account: Account) throws
}
