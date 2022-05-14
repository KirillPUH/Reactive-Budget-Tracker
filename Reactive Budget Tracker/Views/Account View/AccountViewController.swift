//
//  AccountViewController.swift
//  iOS App
//
//  Created by Kirill Pukhov on 13.04.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class AccountViewController: UIViewController, BindableProtocol {

    var viewModel: AccountViewModel!
    
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var accountTableView: UITableView!
    
    var disposeBag: DisposeBag!
    
    private var dataSource: RxTableViewSectionedReloadDataSource<AccountCellModel>!
    
    func bindViewModel() {
        disposeBag = DisposeBag()
        
        doneButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.onDone()
            }
            .disposed(by: self.disposeBag)
        
        cancelButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.onCancel()
            }
            .disposed(by: self.disposeBag)
        
        dataSource = RxTableViewSectionedReloadDataSource<AccountCellModel>(configureCell: { dataSource, tableView, indexPath, cellType in
            switch cellType {
            case .title:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.identifier) as? TextFieldAccountTableViewCell else {
                    fatalError("Can't dequeue reusable cell with \(cellType.identifier) identifier.")
                }
                
                cell.title.text = "Title"
                
                cell.textField.rx.text.asDriver()
                    .drive { [weak self] in
                        self?.viewModel.account.title = $0
                    }
                    .disposed(by: self.disposeBag)
                return cell
            }
        })
        
        viewModel.tableItems
            .bind(to: accountTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}
