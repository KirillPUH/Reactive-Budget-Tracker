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
                    fatalError()
                }
                
                cell.configure(title: "Title", account: self.viewModel.account)
                
                return cell
            case .currency:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.identifier) as? CurrencyAccountTableViewCell else {
                    fatalError()
                }
                
                cell.configure(title: "Currency", account: self.viewModel.account)
                
                return cell
            }
        })
        
        viewModel.tableItems
            .bind(to: accountTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        let firstObserver = viewModel.account.rx.observe(\.title)
        firstObserver
            .subscribe(onNext: { [weak self] in
                if let title = $0, title.isEmpty {
                    self?.doneButton.isEnabled = false
                } else {
                    self?.doneButton.isEnabled = true
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedRowIndexPath = accountTableView.indexPathForSelectedRow {
            accountTableView.deselectRow(at: selectedRowIndexPath, animated: false)
        }
    }
    
}

extension AccountViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if AccountTableViewCellType.allCases[indexPath.row] == .currency {
            let viewModel = CurrenciesViewModel(sceneCoordinator: self.viewModel.sceneCoordinator,
                                                account: self.viewModel.account)
            viewModel.sceneCoordinator.transition(to: .currencies(viewModel), with: .push)
        }
    }
    
}
