//
//  TransactionServiceType.swift
//  iOS App
//
//  Created by Kirill Pukhov on 13.04.2022.
//

import Foundation
import RxSwift

protocol TransactionServiceProtocol {
    func transactions(for account: Account) -> Observable<[Transaction]>
    
    @discardableResult
    func createTransaction(in account: Account) -> Transaction
    
    func delete(transaction: Transaction)
}
