//
//  CurrenciesViewController.swift
//  Reactive Budget Tracker
//
//  Created by Kirill Pukhov on 14.05.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class CurrenciesViewController: UIViewController, BindableProtocol {
    
    public static let storyboardID = "CurrenciesViewController"
    
    public var viewModel: CurrenciesViewModel!
    
    private var disposeBag: DisposeBag!
    
    private var dataSource: RxTableViewSectionedReloadDataSource<CurrencyCellModel>!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func bindViewModel() {
        disposeBag = DisposeBag()
        
        dataSource = RxTableViewSectionedReloadDataSource<CurrencyCellModel>(configureCell: { _, tableView, _, currency in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CurrenciesTableViewCell.identifier) as? CurrenciesTableViewCell else {
                fatalError()
            }
            
            cell.configure(currency: currency)
            
            return cell
        })
        
        tableView.delegate = self
        
        viewModel.tableItems
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
}

extension CurrenciesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.changeCurrency(to: Currency.allCases[indexPath.row])
        viewModel.sceneCoordinator.pop(animated: true)
    }
    
}
