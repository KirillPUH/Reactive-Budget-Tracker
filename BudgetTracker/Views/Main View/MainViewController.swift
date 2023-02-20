import UIKit
import CoreData
import RxSwift
import RxCocoa
import RxDataSources

final class MainViewController: UIViewController, BindableProtocol {
    private typealias DataSourceType = RxTableViewSectionedAnimatedDataSource<TransactionsListSection>
    
    internal var viewModel: MainViewModel!
    
    @IBOutlet var transactionsTableView: UITableView!
    @IBOutlet var plusButton: UIBarButtonItem!
    
    private var disposeBag: DisposeBag!
    
    private var dataSource: DataSourceType!
    
    internal func bindViewModel() {
        disposeBag = DisposeBag()

        bindDataSource()
        bindActions()
        bindProperties()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedRowIndexPath = transactionsTableView.indexPathForSelectedRow {
            transactionsTableView.deselectRow(at: selectedRowIndexPath, animated: true)
        }
    }
    
}

extension MainViewController {
    
    private func bindProperties() {
        viewModel.isPlusButtonEnabled
            .drive(plusButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    private func bindActions() {
        plusButton.rx.tap
            .bind(to: viewModel.createTransactionAction)
            .disposed(by: disposeBag)
        
        transactionsTableView.rx.itemDeleted
            .map { [weak self] indexPath in
                return try! self?.dataSource.model(at: indexPath) as! Transaction
            }
            .bind(to: viewModel.deleteTransactionAction)
            .disposed(by: disposeBag)
        
        transactionsTableView.rx.itemSelected
            .map { [weak self] indexPath in
                return try! self?.dataSource.model(at: indexPath) as! Transaction
            }
            .bind(to: viewModel.selectTransactionAction)
            .disposed(by: disposeBag)
    }
    
    private func bindDataSource() {
        dataSource = DataSourceType(configureCell: { [weak self] _, tableView, _, transaction in
            guard let strongSelf = self else { fatalError() }
            
            return strongSelf.configureCell(for: tableView, transaction: transaction)
        }, titleForHeaderInSection: { dataSource, index in
            return dataSource[index].model
        }, canEditRowAtIndexPath: { _, _ in
            return true
        })
        
        viewModel.tableItems
            .bind(to: transactionsTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    private func configureCell(for tableView: UITableView, transaction: Transaction) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionsTableViewCell.identifier) as? TransactionsTableViewCell else {
            fatalError("Can't dequeue reusable cell with identifier \(TransactionsTableViewCell.identifier)")
        }
        
        cell.configure(transaction)
        
        return cell
    }
    
}
