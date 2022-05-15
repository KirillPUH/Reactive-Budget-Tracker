//
//  TransactionTableViewCellType.swift
//  Reactive Budget Tracker
//
//  Created by Kirill Pukhov on 14.05.2022.
//

import Foundation

enum TransactionTableViewCellType: Int, CaseIterable {
    case title = 0
    case currency
    case amount
    case date
    
    var identifier: String {
        switch self {
        case .title:
            return TextFieldTransactionTableViewCell.identifier
        case .currency:
            return CurrencyTransactionTableViewCell.identifier
        case .amount:
            return TextFieldTransactionTableViewCell.identifier
        case .date:
            return DateTransactionTableViewCell.identifier
        }
    }
}
