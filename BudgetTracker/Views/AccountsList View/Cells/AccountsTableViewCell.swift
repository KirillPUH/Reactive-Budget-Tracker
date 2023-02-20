import UIKit
import RxSwift
import RxCocoa

final class AccountsTableViewCell: UITableViewCell {
    static let identifier = "AccountsTableViewCell"
    
    private static let selectedIndicatorImage = UIImage(systemName: "circle.fill")
    private static let unselectedIndicatorImage = UIImage(systemName: "circle")
    
    private var disposeBag: DisposeBag!
    
    private var tapGesture: UITapGestureRecognizer!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var selectionIndicatorImageView: UIImageView!
    
    private var account: Account!
    
    func configure(with account: Account) {
        disposeBag = DisposeBag()
        
        self.account = account
        titleLabel.text = account.title
        
        tapGesture = UITapGestureRecognizer()
        selectionIndicatorImageView.addGestureRecognizer(tapGesture)
        selectionIndicatorImageView.isUserInteractionEnabled = true
        
        UserDefaults.standard.rx.observe(String.self, "currentAccountUUID")
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { return }
                
                if  let uuidString = $0,
                    let uuid = UUID(uuidString: uuidString),
                    let uuidOfAccount = account.id {
                    // Transition animation for indicator
                    UIView.transition(with: strongSelf.selectionIndicatorImageView,
                                      duration: 0.25,
                                      options: .transitionCrossDissolve) {
                        if uuid == uuidOfAccount {
                            self?.selectionIndicatorImageView.image = Self.selectedIndicatorImage
                        } else {
                            self?.selectionIndicatorImageView.image = Self.unselectedIndicatorImage
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        tapGesture.rx.event.bind(onNext: { _ in
            UserDefaults.standard.set(account.id?.uuidString, forKey: "currentAccountUUID")
        })
        .disposed(by: disposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
}
