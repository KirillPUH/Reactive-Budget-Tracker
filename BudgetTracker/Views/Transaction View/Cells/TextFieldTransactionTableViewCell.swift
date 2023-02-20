import UIKit
import RxSwift
import RxCocoa

enum TextFieldTransactionTableViewCellType {
    case title
    case amount
}

class TextFieldTransactionTableViewCell: UITableViewCell {
    static let identifier = "TextFieldTransactionTableViewCellIdentifier"
    
    private var disposeBag: DisposeBag!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    func configure(for cellType: TextFieldTransactionTableViewCellType, title: String, transaction: Transaction) {
        disposeBag = DisposeBag()
        
        titleLabel.text = title
        
        switch cellType {
        case .title:
            textField.text = transaction.title
            
            textField.rx.text.orEmpty
                .skip(until: textField.rx.controlEvent(.editingDidBegin))
                .take(until: textField.rx.controlEvent(.editingDidEnd))
                .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
                .map { $0 == "" ? nil : $0 }
                .bind(to: transaction.rx.title)
                .disposed(by: disposeBag)
        case .amount:
            textField.text = transaction.amount?.stringValue
            
            textField.rx.text.orEmpty
                .skip(until: textField.rx.controlEvent(.editingDidBegin))
                .take(until: textField.rx.controlEvent(.editingDidEnd))
                .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
                .map { strNumber -> NSNumber? in
                    if strNumber == "" {
                        return nil
                    } else {
                        return NSNumber(value: Double(strNumber) ?? 0)
                    }
                }
                .bind(to: transaction.rx.amount)
                .disposed(by: disposeBag)
        }
    }
    
}
