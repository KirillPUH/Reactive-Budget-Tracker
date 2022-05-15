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
    internal var viewModel: AccountsListViewModel!
    private var disposeBag: DisposeBag!
    private var dataSource: RxTableViewSectionedAnimatedDataSource<AccountsListSection>!
    
    @IBOutlet var accountsTableView: UITableView!
    @IBOutlet var plusButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!

    private func configurePlusButton() {
        plusButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.onCreateAccount()
            }
            .disposed(by: disposeBag)
    }
    
    
    private func configureEditButton() {
        editButton.rx.tap
            .bind { [weak self] in
                guard let strongSelf = self else { return }
                
                self?.accountsTableView.setEditing(!strongSelf.accountsTableView.isEditing, animated: true)
                self?.plusButton.isEnabled.toggle()
            }
            .disposed(by: disposeBag)
    }
    
    private func configureAccountTableView() {
        dataSource = RxTableViewSectionedAnimatedDataSource<AccountsListSection>(configureCell: { dataSource, tableView, indexPath, account in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AccountsTableViewCell.identifier, for: indexPath) as? AccountsTableViewCell else {
                fatalError()
            }
            
            cell.configure(with: account)
            
            return cell
        }, canEditRowAtIndexPath: { [weak self] dataSource, indexPath in
            return (self?.accountsTableView.isEditing ?? false ? true : false)
        }, canMoveRowAtIndexPath: { dataSource, indexPath in
            return true
        })
        
        viewModel.tableItemsSubject
            .bind(to: accountsTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.tableItemsSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] section in
                guard let strongSelf = self else { return }

                if section.first!.items.isEmpty {
                    // FIXME: This next line doesn't work!
                    self?.accountsTableView.setEditing(false, animated: true)
                    self?.editButton.isEnabled = false
                    self?.plusButton.isEnabled = true
                } else {
                    self?.accountsTableView.setEditing(false, animated: false)
                    self?.editButton.isEnabled = true
                    self?.plusButton.isEnabled = (strongSelf.plusButton.isEnabled == false ? false : true)
                }
            })
            .disposed(by: disposeBag)
        
        accountsTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let strongSelf = self else { return }
                
                let viewModel = AccountViewModel(for: strongSelf.viewModel.account(for: indexPath),
                                                 sceneCoordinator: strongSelf.viewModel.sceneCoordinator)
                viewModel.sceneCoordinator.transition(to: .account(viewModel), with: .modal)
            })
            .disposed(by: disposeBag)
        
        accountsTableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.viewModel.onDeleteAccount(at: indexPath)
                    .subscribe(onError: {
                        print($0.localizedDescription)
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        accountsTableView.rx.itemMoved
            .subscribe(onNext: { [weak self] eventElements in
                self?.viewModel.onMoveAccount(from: eventElements.sourceIndex,
                                             to: eventElements.destinationIndex)
            })
            .disposed(by: disposeBag)
    }
    
    public func bindViewModel() {
        disposeBag = DisposeBag()
    
        configurePlusButton()
        configureEditButton()
        configureAccountTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedRowIndexPath = accountsTableView.indexPathForSelectedRow {
            accountsTableView.deselectRow(at: selectedRowIndexPath, animated: false)
        }
    }
    
}
