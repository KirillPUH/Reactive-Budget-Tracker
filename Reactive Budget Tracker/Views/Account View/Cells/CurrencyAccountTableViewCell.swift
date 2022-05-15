//
//  CurrencyAccountTableViewCell.swift
//  Reactive Budget Tracker
//
//  Created by Kirill Pukhov on 15.05.2022.
//

import UIKit
import RxSwift
import RxCocoa

class CurrencyAccountTableViewCell: UITableViewCell {
    
    public static let identifier = "CurrencyAccountTableViewCellIdentifier"
    
    private var disposeBag: DisposeBag!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var currencyLabel: UILabel!
    
    public func configure(title: String, account: Account) {
        disposeBag = DisposeBag()
        
        titleLabel.text = title
        
        account.rx.observe(\.currency)
            .subscribe(onNext: { [weak self] in
                self?.currencyLabel.text = $0
            })
            .disposed(by: disposeBag)
    }
    
}
