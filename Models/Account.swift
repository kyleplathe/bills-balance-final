import Foundation

struct Account: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var type: AccountType
    var balance: Decimal
    var currency: CurrencyType
    var feePercentage: Decimal
}

enum AccountType: String, Codable, CaseIterable {
    case checking
    case savings
    case credit
    case cash
    case investment
    case digitalWallet = "digital_wallet"
}

enum CurrencyType: String, Codable, CaseIterable {
    case usd = "USD"
    case btc = "BTC"
}
