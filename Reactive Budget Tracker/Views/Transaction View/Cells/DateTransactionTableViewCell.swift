//
//  DateTableViewCell.swift
//  iOS App
//
//  Created by Kirill Pukhov on 04.04.2022.
//

import UIKit
import RxSwift
import RxCocoa

class DateTransactionTableViewCell: UITableViewCell {
    static let identifier = "DateTransactionTableViewCellIdentifier"
    
    private var disposeBag: DisposeBag!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!

    func configure(title: String, transaction: Transaction) {
        disposeBag = DisposeBag()
        
        datePicker.date = transaction.date ?? Date()
        
        titleLabel.text = title
        datePicker.rx.date
            .debounce(.milliseconds(50), scheduler: MainScheduler.instance)
            .subscribe {
                transaction.date = $0
            }
            .disposed(by: disposeBag)
    }

}
