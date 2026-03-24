import Foundation

struct Bill: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var amount: Decimal
    var dueDate: Date
    var recurrence: String
    var category: String
    var linkedAccountID: UUID?
    var isPaid: Bool
}
