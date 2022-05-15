//
//  TransactionViewController.swift
//  iOS App
//
//  Created by Kirill Pukhov on 31.03.2022.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa
import RxDataSources

final class TransactionViewController: UIViewController, BindableProtocol {
    private typealias DataSourceType = RxTableViewSectionedReloadDataSource<TransactionCellModel>
    
    var viewModel: TransactionViewModel!
    
    private var disposeBag: DisposeBag!
    
    private var dataSource: DataSourceType!
    
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    
    func bindViewModel() {
        disposeBag = DisposeBag()
        
        doneButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.viewModel.onDone()
            })
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.viewModel.onCancel()
            })
            .disposed(by: disposeBag)
        
        dataSource = DataSourceType(configureCell: { [weak self] dataSource, tableView, indexPath, cellType in
            guard let strongSelf = self else { return UITableViewCell() }
    
            switch cellType {
            case .title:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.identifier) as? TextFieldTransactionTableViewCell else {
                    fatalError()
                }

                cell.configure(for: .title, title: "Title", transaction: strongSelf.viewModel.transaction)
                
                return cell
            case .currency:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.identifier) as? CurrencyTransactionTableViewCell else {
                    fatalError()
                }
                cell.configure(title: "Currency", transaction: strongSelf.viewModel.transaction)
                
                return cell
            case .amount:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.identifier) as? TextFieldTransactionTableViewCell else {
                    fatalError()
                }

                cell.configure(for: .amount, title: "Amount", transaction: strongSelf.viewModel.transaction)

                return cell
            case .date:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.identifier) as? DateTransactionTableViewCell else {
                    fatalError()
                }

                cell.configure(title: "Date", transaction: strongSelf.viewModel.transaction)
                
                return cell
            }
        })
        
        viewModel.tableItems
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        let firstObserver = viewModel.transaction.rx.observe(\.title)
        let secondObserver = viewModel.transaction.rx.observe(\.amount)
        
        Observable.combineLatest(firstObserver, secondObserver)
            .subscribe(onNext: { [weak self] title, amount in
                if let title = title, !title.isEmpty,
                   let _ = amount {
                    self?.doneButton.isEnabled = true
                } else {
                    self?.doneButton.isEnabled = false
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRowIndexPath, animated: false)
        }
    }
}

extension TransactionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        TransactionTableViewCellType(rawValue: indexPath.row) == .currency
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if TransactionTableViewCellType(rawValue: indexPath.row) == .currency {
            let viewModel = CurrenciesViewModel(sceneCoordinator: viewModel.sceneCoordinator, transaction: viewModel.transaction)
            viewModel.sceneCoordinator.transition(to: .currencies(viewModel), with: .push)
        }
    }
}
