//
//  TextFieldAccountTableViewCell.swift
//  iOS App
//
//  Created by Kirill Pukhov on 16.04.2022.
//

import UIKit
import RxSwift
import RxCocoa

class TextFieldAccountTableViewCell: UITableViewCell {
    static let identifier = "TextFieldAccountTableViewCellIdentifier"
    
    private var disposeBag: DisposeBag!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textField: UITextField!
    
    func configure(title: String, account: Account) {
        disposeBag = DisposeBag()
        
        titleLabel.text = title
        
        textField.text = account.title
        
        textField.rx.text
            .asDriver()
            .drive {
                account.title = $0
            }
            .disposed(by: disposeBag)
    }

}
