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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(title: String, transaction: Transaction) {
        disposeBag = DisposeBag()
        
        currencyLabel.text = transaction.currency
        
        titleLabel.text = title
        transaction.rx.observe(\.currency)
            .subscribe(onNext: { [weak self] in
                self?.currencyLabel.text = $0
            })
            .disposed(by: disposeBag)
    }
}
