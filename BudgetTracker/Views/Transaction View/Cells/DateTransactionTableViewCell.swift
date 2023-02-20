import UIKit
import RxSwift
import RxCocoa

class DateTransactionTableViewCell: UITableViewCell {
    static let identifier = "DateTransactionTableViewCellIdentifier"
    
    private var disposeBag: DisposeBag!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!

    func configure(title: String, transaction: Transaction) {
        disposeBag = DisposeBag()
        
        titleLabel.text = title
        
        datePicker.date = transaction.date ?? Date()
        
        datePicker.rx.controlEvent(.editingDidEnd)
            .withLatestFrom(datePicker.rx.date)
            .bind(to: transaction.rx.date)
            .disposed(by: disposeBag)
    }
    
}
