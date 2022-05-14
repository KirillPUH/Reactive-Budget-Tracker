//
//  DateTableViewCell.swift
//  iOS App
//
//  Created by Kirill Pukhov on 04.04.2022.
//

import UIKit

class DateTransactionTableViewCell: UITableViewCell {
    static let identifier = "DateTransactionTableViewCellIdentifier"
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
