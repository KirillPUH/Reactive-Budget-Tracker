//
//  TextFieldAccountTableViewCell.swift
//  iOS App
//
//  Created by Kirill Pukhov on 16.04.2022.
//

import UIKit

class TextFieldAccountTableViewCell: UITableViewCell {
    static let identifier = "TextFieldAccountTableViewCell"
    
    @IBOutlet var title: UILabel!
    @IBOutlet var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
