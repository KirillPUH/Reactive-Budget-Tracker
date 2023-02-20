import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class AccountViewController: UIViewController, BindableProtocol {

    public var viewModel: AccountViewModel!
    
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var accountTableView: UITableView!
    
    private var disposeBag: DisposeBag!
    
    private var dataSource: RxTableViewSectionedReloadDataSource<AccountCellModel>!
    
    internal func bindViewModel() {
        disposeBag = DisposeBag()
        
        bindActions()
        bindProperties()
        bindDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedRowIndexPath = accountTableView.indexPathForSelectedRow {
            accountTableView.deselectRow(at: selectedRowIndexPath, animated: false)
        }
    }
    
}

extension AccountViewController {
    
    private func bindActions() {
        doneButton.rx.tap
            .bind(to: viewModel.doneAction)
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .bind(to: viewModel.cancelAction)
            .disposed(by: disposeBag)
        
        accountTableView.rx.itemSelected
            .take(while: { AccountTableViewCellType(rawValue: $0.row) == .currency })
            .map { _ in }
            .bind(to: viewModel.chooseCurrencyAction)
            .disposed(by: disposeBag)
    }
    
    private func bindProperties() {
        viewModel.isDoneButtonEnabled
            .drive(doneButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    private func bindDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource<AccountCellModel>(configureCell: { [weak self] dataSource, tableView, indexPath, cellType in
            guard let strongSelf = self else { fatalError() }
            
            return cellType.configureCell(for: tableView, account: strongSelf.viewModel.account)
        })
        
        viewModel.tableItems
            .bind(to: accountTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
}
