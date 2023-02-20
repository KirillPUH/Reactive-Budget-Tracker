import UIKit
import RxSwift
import RxCocoa

class TransactionsTableViewCell: UITableViewCell {
    static let identifier = "TransactionsTableViewCell"
    
    private var disposeBag: DisposeBag!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var convertedAmountLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
    
    private static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    func configure(_ transaction: Transaction) {
        disposeBag = DisposeBag()
        
        transaction.rx.observe(\.title)
            .asDriver(onErrorJustReturn: nil)
            .map { title in
                return title ?? "Title"
            }
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        let amountObserver = transaction.rx.observe(\.amount)
            .map { amount in
                return amount ?? 0
            }
        let convertedAmountObserver = transaction.rx.observe(\.convertedAmount)
        let transactionCurrencyObserver = transaction.rx.observe(\.currency)
            .map { transactionCurrency in
                return transactionCurrency ?? Currency.usd.rawValue
            }
        let accountCurrencyObserver = transaction.account!.rx.observe(\.currency)
            .map { accountCurrency in
                return accountCurrency ?? Currency.usd.rawValue
            }

        Observable.combineLatest(amountObserver,
                                 transactionCurrencyObserver,
                                 convertedAmountObserver,
                                 accountCurrencyObserver)
        .subscribe(onNext: { [weak self] amount, transactionCurrency, convertedAmount, accountCurrency in
            if let convertedAmount = convertedAmount {
                self?.convertedAmountLabel.text = "\(Self.amountFormatter.string(from: convertedAmount)!) \(accountCurrency)"
                self?.amountLabel.isHidden = false
                self?.amountLabel.text = "\(Self.amountFormatter.string(from: amount)!) \(transactionCurrency)"
            } else {
                self?.convertedAmountLabel.text = "\(Self.amountFormatter.string(from: amount)!) \(transactionCurrency)"
                self?.amountLabel.isHidden = true
            }
        })
        .disposed(by: disposeBag)
        
        transaction.rx.observe(\.date)
            .asDriver(onErrorJustReturn: nil)
            .map { date in
                return Self.dateFormatter.string(from: date ?? Date())
            }
            .drive(dateLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
}
