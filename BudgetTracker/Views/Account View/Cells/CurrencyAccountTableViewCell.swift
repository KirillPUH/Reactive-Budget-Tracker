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
            .bind(to: currencyLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
}
