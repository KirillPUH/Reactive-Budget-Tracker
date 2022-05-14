//
//  AccountsTableViewCell.swift
//  iOS App
//
//  Created by Kirill Pukhov on 28.03.2022.
//

import UIKit

class AccountsTableViewCell: UITableViewCell {
    static let identifier = "AccountsTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    
    private var account: Account!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with account: Account) {
        self.account = account
        titleLabel.text = account.title
    }
    
}
