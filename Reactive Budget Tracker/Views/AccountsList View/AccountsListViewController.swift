//
//  AccountsListViewController.swift
//  iOS App
//
//  Created by Kirill Pukhov on 28.03.2022.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa
import RxDataSources

final class AccountsListViewController: UIViewController, BindableProtocol {
    private typealias DataSourceType = RxTableViewSectionedAnimatedDataSource<AccountsListSection>
    
    internal var viewModel: AccountsListViewModel!
    
    @IBOutlet var accountsTableView: UITableView!
    @IBOutlet var plusButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    
    private var disposeBag: DisposeBag!
    private var dataSource: DataSourceType!
    
    public func bindViewModel() {
        disposeBag = DisposeBag()
        
        bindDataSource()
        bindProperties()
        bindActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedRowIndexPath = accountsTableView.indexPathForSelectedRow {
            accountsTableView.deselectRow(at: selectedRowIndexPath, animated: false)
        }
    }
    
}

extension AccountsListViewController {
    
    private func bindActions() {
        plusButton.rx.tap
            .bind(to: viewModel.createAccountAction)
            .disposed(by: disposeBag)
        
        editButton.rx.tap
            .bind(to: viewModel.editButtonAction)
            .disposed(by: disposeBag)
        
        accountsTableView.rx.itemDeleted
            .map { [weak self] indexPath in
                return try! self?.dataSource.model(at: indexPath) as! Account
            }
            .bind(to: viewModel.deleteAccountAciton)
            .disposed(by: disposeBag)
        
        accountsTableView.rx.itemSelected
            .map { [weak self] indexPath in
                return try! self?.dataSource.model(at: indexPath) as! Account
            }
            .bind(to: viewModel.selectAccountAction)
            .disposed(by: disposeBag)
    }
    
    private func bindProperties() {
        viewModel.isTableViewEditing
            .drive(accountsTableView.rx.isEditing)
            .disposed(by: disposeBag)
        
        viewModel.isPlusButtonEnabled
            .drive(plusButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.isEditButtonEnabled
            .drive(editButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.isTableViewEditing
            .drive(onNext: { [weak self] isEnabled in
                self?.accountsTableView.setEditing(isEnabled, animated: false)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindDataSource() {
        dataSource = DataSourceType(configureCell: { dataSource, tableView, indexPath, account in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AccountsTableViewCell.identifier, for: indexPath) as? AccountsTableViewCell else {
                fatalError()
            }
            
            cell.configure(with: account)
            
            return cell
        }, canEditRowAtIndexPath: { _, _ in
            return true
        })
        
        viewModel.tableItems
            .bind(to: accountsTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
}
