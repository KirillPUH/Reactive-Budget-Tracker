import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class CurrenciesViewController: UIViewController, BindableProtocol {
    
    public static let storyboardID = "CurrenciesViewController"
    
    public var viewModel: CurrenciesViewModel!
    
    private var disposeBag: DisposeBag!
    
    private var dataSource: RxTableViewSectionedReloadDataSource<CurrencyCellModel>!
    
    @IBOutlet var tableView: UITableView!
    
    func bindViewModel() {
        disposeBag = DisposeBag()
        
        dataSource = RxTableViewSectionedReloadDataSource<CurrencyCellModel>(configureCell: { _, tableView, _, currency in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CurrenciesTableViewCell.identifier) as? CurrenciesTableViewCell else {
                fatalError()
            }
            
            cell.configure(currency: currency)
            
            return cell
        })
        
        viewModel.tableItems
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        navigationItem.leftBarButtonItem?.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.viewModel.sceneCoordinator.pop(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        navigationItem.hidesBackButton = false
        
        let backButton = UIBarButtonItem(title: "Back")
        navigationItem.leftBarButtonItem = backButton
    
        navigationItem.title = "Currency"
    }
    
}

extension CurrenciesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.changeCurrency(to: Currency.allCases[indexPath.row])
        viewModel.sceneCoordinator.pop(animated: true)
    }
    
}
