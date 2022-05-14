//
//  TextFieldTableViewCell.swift
//  iOS App
//
//  Created by Kirill Pukhov on 04.04.2022.
//

import UIKit

class TextFieldTransactionTableViewCell: UITableViewCell {
    static let identifier = "TextFieldTransactionTableViewCellIdentifier"
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
