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

class AccountsListViewController: UIViewController, BindableProtocol {
    var viewModel: AccountsListViewModel!
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
                self?.accountsTableView.isEditing.toggle()
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
            .subscribe(onNext: { [weak self] section in
                guard let self = self else { return }
                
                if section.first!.items.isEmpty {
                    self.isEditing = false
                    self.editButton.isEnabled = false
                    self.plusButton.isEnabled = true
                } else {
                    self.editButton.isEnabled = true
                    self.plusButton.isEnabled = (self.plusButton.isEnabled == false ? false : true)
                }
            })
            .disposed(by: disposeBag)
        
        accountsTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.viewModel.onSelectAccount(at: indexPath)
            })
            .disposed(by: disposeBag)
        
        accountsTableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.viewModel.onDeleteAccount(at: indexPath)
                    .subscribe(onError: { error in
                        print(error.localizedDescription)
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
    
    func bindViewModel() {
        disposeBag = DisposeBag()
    
        configurePlusButton()
        configureEditButton()
        configureAccountTableView()
    }
}
