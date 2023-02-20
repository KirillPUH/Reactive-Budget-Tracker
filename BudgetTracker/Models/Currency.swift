import Foundation

enum Currency: String, CaseIterable {
    case usd = "USD"
    case eur = "EUR"
    case rub = "RUB"
    case byn = "BYN"
    case uah = "UAH"
    case gbp = "GBP"
    
    var fullName: String {
        switch self {
        case .usd:
            return "United States Dollar"
        case .eur:
            return "Euro"
        case .rub:
            return "Russian Ruble"
        case .byn:
            return "New Belarussian Ruble"
        case .uah:
            return "Ukrainian Hryvnia"
        case .gbp:
            return "Great Britain Pound"
        }
    }
}
