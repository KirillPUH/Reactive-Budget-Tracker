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
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
    
    private static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    func configure(_ transaction: Transaction) {
        titleLabel.text = transaction.title
        
        guard let amount = transaction.amount,
              let transactionCurrency = transaction.currency,
              let date = transaction.date else {
            return
        }
        
        if let convertedAmount = transaction.convertedAmount,
           let accountCurrency = transaction.account?.currency {
            convertedAmountLabel.text = "\(Self.amountFormatter.string(from: convertedAmount)!) \(accountCurrency)"
            amountLabel.isHidden = false
            amountLabel.text = "\(Self.amountFormatter.string(from: amount)!) \(transactionCurrency)"
        } else {
            convertedAmountLabel.text = "\(Self.amountFormatter.string(from: amount)!) \(transactionCurrency)"
            amountLabel.isHidden = true
        }
        
        dateLabel.text = Self.dateFormatter.string(from: date)
    }
    
}
