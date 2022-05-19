//
//  AccountTableViewCellType.swift
//  Reactive Budget Tracker
//
//  Created by Kirill Pukhov on 15.05.2022.
//

import Foundation
import UIKit

enum AccountTableViewCellType: Int, CaseIterable {
    case title = 0
    case currency
}

extension AccountTableViewCellType {
    
    private var identifier: String {
        switch self {
        case .title:
            return TextFieldAccountTableViewCell.identifier
        case .currency:
            return CurrencyAccountTableViewCell.identifier
        }
    }
    
    public func configureCell(for tableView: UITableView, account: Account) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) else {
            fatalError("Can't dequeue reusable cell ")
        }
        
        switch self {
        case .title:
            if let cell = cell as? TextFieldAccountTableViewCell {
                cell.configure(title: "Title", account: account)
                return cell
            } else {
                return transformationError()
            }
        case .currency:
            if let cell = cell as? CurrencyAccountTableViewCell {
                cell.configure(title: "Currency", account: account)
                return cell
            } else {
                return transformationError()
            }
        }
    }
    
    private func transformationError() -> UITableViewCell {
        print("Can't transform cell to \(identifier)")
        return UITableViewCell()
    }
    
}
