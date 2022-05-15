//
//  CurrenciesViewModel.swift
//  Reactive Budget Tracker
//
//  Created by Kirill Pukhov on 14.05.2022.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

typealias CurrencyCellModel = SectionModel<String, Currency>

class CurrenciesViewModel {
    
    public var sceneCoordinator: SceneCoordinatorProtocol
    
    private var transaction: Transaction
    
    public var tableItems: Observable<[CurrencyCellModel]>
    
    init(sceneCoordinator: SceneCoordinatorProtocol, transaction: Transaction) {
        self.sceneCoordinator = sceneCoordinator
        
        self.transaction = transaction
        
        tableItems = Observable.create {
            $0.onNext([CurrencyCellModel(model: "Currencies",
                                         items: Currency.allCases)])
            return Disposables.create { }
        }
    }
    
    func changeCurrency(to currency: Currency) {
        transaction.currency = currency.rawValue
    }
    
}
