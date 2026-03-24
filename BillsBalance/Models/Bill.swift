import Foundation

struct Bill: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var amount: Decimal
    var dueDate: Date
    var recurrence: String
    var category: String
    /// Displayed as payment source (e.g. "Apple Card").
    var paymentMethod: String
    var linkedAccountID: UUID?
    var isPaid: Bool
    /// Shown with lightning bolt in list (e.g. autopay).
    var isAutoPay: Bool

    enum RowStatus: Sendable {
        case paid
        case upcoming
        case dueSoon
        case overdue
    }

    func rowStatus(referenceDate: Date = .now) -> RowStatus {
        if isPaid { return .paid }
        let cal = Calendar.current
        let ref = cal.startOfDay(for: referenceDate)
        let due = cal.startOfDay(for: dueDate)
        if due < ref { return .overdue }
        let days = cal.dateComponents([.day], from: ref, to: due).day ?? 0
        if days <= 3 { return .dueSoon }
        return .upcoming
    }

    func daysOffsetFromToday(referenceDate: Date = .now) -> Int {
        let cal = Calendar.current
        let ref = cal.startOfDay(for: referenceDate)
        let due = cal.startOfDay(for: dueDate)
        return cal.dateComponents([.day], from: ref, to: due).day ?? 0
    }

    var recurrenceLabel: String {
        switch recurrence.lowercased() {
        case "monthly": return "Monthly"
        case "semi-annually", "semiannually": return "Semi-annually"
        case "weekly": return "Weekly"
        case "yearly", "annual": return "Yearly"
        default: return recurrence.capitalized
        }
    }

    init(
        id: UUID,
        name: String,
        amount: Decimal,
        dueDate: Date,
        recurrence: String,
        category: String,
        paymentMethod: String = "Apple Card",
        linkedAccountID: UUID?,
        isPaid: Bool,
        isAutoPay: Bool = false
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.dueDate = dueDate
        self.recurrence = recurrence
        self.category = category
        self.paymentMethod = paymentMethod
        self.linkedAccountID = linkedAccountID
        self.isPaid = isPaid
        self.isAutoPay = isAutoPay
    }

    enum CodingKeys: String, CodingKey {
        case id, name, amount, dueDate, recurrence, category, paymentMethod, linkedAccountID, isPaid, isAutoPay
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        amount = try c.decode(Decimal.self, forKey: .amount)
        dueDate = try c.decode(Date.self, forKey: .dueDate)
        recurrence = try c.decode(String.self, forKey: .recurrence)
        category = try c.decode(String.self, forKey: .category)
        paymentMethod = try c.decodeIfPresent(String.self, forKey: .paymentMethod) ?? "Apple Card"
        linkedAccountID = try c.decodeIfPresent(UUID.self, forKey: .linkedAccountID)
        isPaid = try c.decode(Bool.self, forKey: .isPaid)
        isAutoPay = try c.decodeIfPresent(Bool.self, forKey: .isAutoPay) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(amount, forKey: .amount)
        try c.encode(dueDate, forKey: .dueDate)
        try c.encode(recurrence, forKey: .recurrence)
        try c.encode(category, forKey: .category)
        try c.encode(paymentMethod, forKey: .paymentMethod)
        try c.encodeIfPresent(linkedAccountID, forKey: .linkedAccountID)
        try c.encode(isPaid, forKey: .isPaid)
        try c.encode(isAutoPay, forKey: .isAutoPay)
    }
}
