import Foundation

struct LedgerTransaction: Identifiable, Codable, Hashable {
    let id: UUID
    var accountID: UUID
    var amount: Decimal
    var date: Date
    var type: String
    var status: TransactionStatus
    var btcSats: Int64?
    var btcPrice: Decimal?
    var billID: UUID?
}

enum TransactionStatus: String, Codable, CaseIterable {
    case cleared
    case pending
}
