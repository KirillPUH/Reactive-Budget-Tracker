//
//  TextFieldTableViewCell.swift
//  iOS App
//
//  Created by Kirill Pukhov on 04.04.2022.
//

import UIKit
import RxSwift
import RxCocoa

enum TextFieldTransactionTableViewCellType {
    case title
    case amount
}

class TextFieldTransactionTableViewCell: UITableViewCell {
    static let identifier = "TextFieldTransactionTableViewCellIdentifier"
    
    private var disposeBag: DisposeBag!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    func configure(for cellType: TextFieldTransactionTableViewCellType, title: String, transaction: Transaction) {
        disposeBag = DisposeBag()
        
        
        titleLabel.text = title
        
        switch cellType {
        case .title:
            textField.text = transaction.title
            textField.rx.text
                .orEmpty
                .debounce(.milliseconds(50), scheduler: MainScheduler.instance)
                .subscribe(onNext: {
                    transaction.title = $0
                })
                .disposed(by: disposeBag)
        case .amount:
            textField.text = transaction.amount?.stringValue
            textField.rx.text
                .orEmpty
                .debounce(.milliseconds(50), scheduler: MainScheduler.instance)
                .subscribe(onNext: {
                    if let number = Double($0) {
                        transaction.amount = NSNumber(value: number)
                    }
                })
                .disposed(by: disposeBag)
        }
    }
    
}
