//
//  TransactionServiceType.swift
//  iOS App
//
//  Created by Kirill Pukhov on 13.04.2022.
//

import Foundation
import RxSwift

protocol TransactionServiceProtocol {
    var currentAccount: BehaviorSubject<Account?> { get }
    
    var currentTransactions: BehaviorSubject<[Transaction]> { get }
    
    func transactions(for account: Account) -> Observable<[Transaction]>
    
    func createTransaction(in account: Account) -> Single<Transaction>
    
    @discardableResult
    func delete(transaction: Transaction) -> Completable
}
