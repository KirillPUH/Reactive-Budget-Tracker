//
//  ViewController.swift
//  iOS App
//
//  Created by Kirill Pukhov on 14.03.2022.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa
import RxDataSources

class MainViewController: UIViewController, BindableProtocol {
    var viewModel: MainViewModel!
    
    private var disposeBag: DisposeBag!
    private var dataSource: RxTableViewSectionedAnimatedDataSource<TransactionsListModel>!
    
    @IBOutlet var transactionsTableView: UITableView!
    @IBOutlet var plusButton: UIBarButtonItem!
    
    func bindViewModel() {
        disposeBag = DisposeBag()
        
        viewModel.transactionService.currentAccount
            .subscribe(onNext: { [weak self] in
                self?.plusButton.isEnabled = ($0 == nil ? false : true)
            })
            .disposed(by: disposeBag)
        
        plusButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.onCreateTransaction()
            }
            .disposed(by: disposeBag)
        
        dataSource = RxTableViewSectionedAnimatedDataSource<TransactionsListModel>(configureCell: { _, tableView, _, transaction in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionsTableViewCell.identifier) as? TransactionsTableViewCell else {
                fatalError("Can't dequeue reusable cell with identifier \(TransactionsTableViewCell.identifier)")
            }
            cell.configure(transaction)
            return cell
        }, titleForHeaderInSection: { dataSource, index in
            dataSource[index].model
        }, canEditRowAtIndexPath: { _, _ in
            true
        })
        
        viewModel.tableItemsSubject
            .bind(to: transactionsTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        transactionsTableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] in
                self?.viewModel.onDeleteTransaction(at: $0)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transactionsTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedRowIndexPath = transactionsTableView.indexPathForSelectedRow {
            transactionsTableView.deselectRow(at: selectedRowIndexPath, animated: true)
        }
    }
    
}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = TransactionViewModel(for: self.viewModel.transaction(for: indexPath),
                                             sceneCoordinator: self.viewModel.sceneCoordinator)
        self.viewModel.sceneCoordinator.transition(to: .transaction(viewModel), with: .modal)
    }
    
}
