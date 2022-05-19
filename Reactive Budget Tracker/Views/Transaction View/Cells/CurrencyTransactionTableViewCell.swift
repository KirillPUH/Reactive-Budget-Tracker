//
//  CurrencyTransactionTableViewCell.swift
//  Reactive Budget Tracker
//
//  Created by Kirill Pukhov on 14.05.2022.
//

import UIKit
import RxSwift
import RxCocoa

class CurrencyTransactionTableViewCell: UITableViewCell {
    static let identifier = "CurrencyTransactionTableViewCellIdentifier"
    
    private var disposeBag: DisposeBag!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var currencyLabel: UILabel!

    func configure(title: String, transaction: Transaction) {
        disposeBag = DisposeBag()
        
        currencyLabel.text = transaction.currency
        
        titleLabel.text = title
        
        transaction.rx.observe(\.currency)
            .bind(to: currencyLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
}
