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
        
        titleLabel.text = title
        
        currencyLabel.text = transaction.currency ?? Currency.usd.rawValue
        
        transaction.rx.observe(\.currency)
            .bind(to: currencyLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
}
