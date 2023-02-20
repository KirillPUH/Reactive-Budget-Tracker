import UIKit

final class CurrenciesTableViewCell: UITableViewCell {

    public static let identifier = "CurrenciesTableViewCellIdentifier"
    
    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    public func configure(currency: Currency) {
        titleLabel.text = currency.rawValue
    }
    
}
