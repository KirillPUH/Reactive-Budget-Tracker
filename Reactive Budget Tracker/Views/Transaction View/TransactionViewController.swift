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
    
    var viewModel: TransactionViewModel!
    
    private var disposeBag: DisposeBag!
    
    private var dataSource: RxTableViewSectionedReloadDataSource<TransactionCellModel>!
    
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
        
        dataSource = RxTableViewSectionedReloadDataSource<TransactionCellModel>(configureCell: { [weak self] dataSource, tableView, indexPath, cellType in
            guard let self = self else { return UITableViewCell() }
    
            switch cellType {
            case .title:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.identifier) as? TextFieldTransactionTableViewCell else {
                    fatalError()
                }

                cell.label.text = "Title"
                cell.textField.rx.text
                    .orEmpty
                    .debounce(.milliseconds(50), scheduler: MainScheduler.instance)
                    .subscribe { [weak self] in
                        self?.viewModel.transaction.title = $0
                    }
                    .disposed(by: self.disposeBag)
                
                return cell
            case .currency:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.identifier) as? TextFieldTransactionTableViewCell else {
                    fatalError()
                }

                cell.label.text = "Currency"
                cell.textField.rx.text
                    .orEmpty
                    .debounce(.milliseconds(50), scheduler: MainScheduler.instance)
                    .subscribe { [weak self] in
                        self?.viewModel.transaction.currency = $0
                    }
                    .disposed(by: self.disposeBag)
                
                return cell
            case .amount:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.identifier) as? TextFieldTransactionTableViewCell else {
                    fatalError()
                }

                cell.label.text = "Amount"
                cell.textField.rx.text
                    .debounce(.milliseconds(50), scheduler: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] in
                        if let str = $0, let num = Double(str) {
                            self?.viewModel.transaction.amount = NSNumber(value: num)
                        }
                    })
                    .disposed(by: self.disposeBag)

                return cell
            case .date:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.identifier) as? DateTransactionTableViewCell else {
                    fatalError()
                }

                cell.label.text = "Date"
                cell.datePicker.rx.date
                    .debounce(.milliseconds(50), scheduler: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] in
                        self?.viewModel.transaction.date = $0
                    })
                    .disposed(by: self.disposeBag)
                
                return cell
            }
        })
        
        viewModel.tableItems
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}
