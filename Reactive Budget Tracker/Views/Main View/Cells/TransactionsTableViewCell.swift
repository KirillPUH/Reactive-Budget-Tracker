//
//  TransactionsTableViewCell.swift
//  iOS App
//
//  Created by Kirill Pukhov on 28.03.2022.
//

import UIKit

class TransactionsTableViewCell: UITableViewCell {
    static let identifier = "TransactionsTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var convertedAmountLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ transaction: Transaction) {
        titleLabel.text = transaction.title
        if let convertedAmount = transaction.convertedAmount as? Double {
            convertedAmountLabel.text = "\(String(convertedAmount)) \(transaction.account!.currency!)"
        }
        
        if let date = transaction.date {
            dateLabel.text = dateFormatter.string(from: date)
        }
        
        if let amount = transaction.amount as? Double {
            amountLabel.text = "\(String(amount)) \(transaction.currency!)"
        }
    }

}
