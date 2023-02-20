import UIKit

enum TransactionTableViewCellType: Int, CaseIterable {
    case title = 0
    case currency
    case amount
    case date
}

extension TransactionTableViewCellType {
    private var identifier: String {
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
    
    public func configureCell(for tableView: UITableView, transaction: Transaction) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) else {
            fatalError("Can't dequeue reusable cell with identifier \(identifier)")
        }
        
        switch self {
        case .title:
            if let cell = cell as? TextFieldTransactionTableViewCell {
                cell.configure(for: .title, title: "Title", transaction: transaction)
                return cell
            } else {
                return transformationError()
            }
        case .currency:
            if let cell = cell as? CurrencyTransactionTableViewCell {
                cell.configure(title: "Currency", transaction: transaction)
                return cell
            } else {
                return transformationError()
            }
        case .amount:
            if let cell = cell as? TextFieldTransactionTableViewCell {
                cell.configure(for: .amount, title: "Amount", transaction: transaction)
                return cell
            } else {
                return transformationError()
            }
        case .date:
            if let cell = cell as? DateTransactionTableViewCell {
                cell.configure(title: "Date", transaction: transaction)
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
