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
    
    internal var viewModel: TransactionViewModel!
    
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    
    private var disposeBag: DisposeBag!
    
    private var dataSource: DataSourceType!

    func bindViewModel() {
        disposeBag = DisposeBag()
        
        bindActions()
        bindProperties()
        bindDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRowIndexPath, animated: false)
        }
    }
    
}

extension TransactionViewController {
    
    func bindActions() {
        doneButton.rx.tap
            .bind(to: viewModel.doneAction)
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .bind(to: viewModel.cancelAction)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .take(while: { TransactionTableViewCellType(rawValue: $0.row) == .currency })
            .map { _ in }
            .bind(to: viewModel.chooseCurrencyAction)
            .disposed(by: disposeBag)
    }
    
    func bindProperties() {
        viewModel.isDoneButtonEnabled
            .drive(doneButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    func bindDataSource() {
        dataSource = DataSourceType(configureCell: { [weak self] dataSource, tableView, indexPath, cellType in
            guard let strongSelf = self else { return UITableViewCell() }
    
            return cellType.configureCell(for: tableView, transaction: strongSelf.viewModel.transaction)
        })
        
        viewModel.tableItems
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
}
