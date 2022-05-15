//
//  AccountTableViewCellType.swift
//  Reactive Budget Tracker
//
//  Created by Kirill Pukhov on 15.05.2022.
//

import Foundation

enum AccountTableViewCellType: CaseIterable {
    case title
    case currency
    
    var identifier: String {
        switch self {
        case .title:
            return TextFieldAccountTableViewCell.identifier
        case .currency:
            return CurrencyAccountTableViewCell.identifier
        }
    }
}
