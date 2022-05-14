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
    
//    private var context: NSManagedObjectContext!
//
//    private var contextObservers = [NSObjectProtocol]()
//
//    private var currentAccountUUID: UUID?
//    var account: Account?
//    var transactions: [Transaction]!
    
    private var disposeBag: DisposeBag!
    private var dataSource: RxTableViewSectionedAnimatedDataSource<TransactionsListModel>!
    
    @IBOutlet var transactionsTableView: UITableView!
    @IBOutlet var plusButton: UIBarButtonItem!
    
    func bindViewModel() {
        disposeBag = DisposeBag()
        
        viewModel.transactionService.currentAccount
            .subscribe(onNext: { [weak self] account in
                if account == nil {
                    self?.plusButton.isEnabled = false
                } else {
                    self?.plusButton.isEnabled = true
                }
            })
            .disposed(by: disposeBag)
        
        plusButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.onCreateTransaction()
            }
            .disposed(by: disposeBag)
        
        dataSource = RxTableViewSectionedAnimatedDataSource<TransactionsListModel>(configureCell: { dataSource, tableView, indexPath, transaction in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionsTableViewCell.identifier) as? TransactionsTableViewCell else {
                fatalError("Can't dequeue reusable cell with identifier \(TransactionsTableViewCell.identifier)")
            }

            cell.configure(transaction)
            return cell
        }, titleForHeaderInSection: { dataSource, index in
            return dataSource[index].model
        }, canEditRowAtIndexPath: { dataSource, indexPath in
            return true
        })
        
        viewModel.tableItemsSubject
            .bind(to: transactionsTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        transactionsTableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                self?.viewModel.onDeleteTransaction(at: indexPath)
            })
            .disposed(by: disposeBag)
    }
}
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
//
//        contextObservers.append(
//            NotificationCenter.default.addObserver(forName: NSManagedObjectContext.didSaveObjectsNotification, object: context, queue: .main) { [weak self] _ in
//                self?.getTransactions()
//                self?.transactionsTableView.reloadData()
//            }
//        )
//
//        transactionsTableView.dataSource = self
//        transactionsTableView.delegate = self
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//    }
//
//    private func performAccountFetch() {
//        do {
//            guard let currentAccountUUID = currentAccountUUID else {
//                print("currentAccountUUID isn't set")
//                return
//            }
//
//            let fetchRequest = Account.fetchRequest()
//            let predicate = NSPredicate(format: "id == %@", currentAccountUUID.uuidString)
//            fetchRequest.predicate = predicate
//
//            account = try context.fetch(fetchRequest).first
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
//
//    private func getTransactions() {
//        let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
//        let titleSortDescriptor = NSSortDescriptor(key: "title", ascending: true)
//
//        guard let transactions = account?.transactions?.sortedArray(using: [dateSortDescriptor, titleSortDescriptor]) as? [Transaction] else {
//            transactions = []
//            return
//        }
//        self.transactions = transactions
//    }
//}
//
//extension MainViewController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let nextVC = storyboard.instantiateViewController(withIdentifier: "TransactionViewControllerIdentifier") as? TransactionViewController {
//            nextVC.transaction = transactions[indexPath.row]
//            present(nextVC, animated: true)
//        }
//    }
//
//    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
//
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let contextualAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, _ in
//            guard let transactions = self?.transactions else {
//                return
//            }
//
//            self?.account?.removeFromTransactions(transactions[indexPath.row])
//            self?.getTransactions()
//
//            self?.transactionsTableView.beginUpdates()
//            self?.transactionsTableView.deleteRows(at: [indexPath], with: .automatic)
//            self?.transactionsTableView.endUpdates()
//
//            do {
//                try self?.context.save()
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//
//        contextualAction.image = UIImage(systemName: "trash.fill")
//
//        return UISwipeActionsConfiguration(actions: [contextualAction])
//    }
//
//}
//
//extension MainViewController: UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch tableView {
//        case transactionsTableView:
//            return 0
//        default:
//            fatalError("Unknown UITableView instanse")
//        }
//    }
//
//}
