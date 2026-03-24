import Foundation
import PostgREST
import Supabase

final class LedgerService {
    private let database: DatabaseManager

    init(database: DatabaseManager = .shared) {
        self.database = database
    }

    /// Handles the Bill `is_paid` toggle and keeps Ledger + Balance synced.
    func syncBillPaymentToggle(updatedBill: Bill, previousIsPaid: Bool) async throws {
        guard !previousIsPaid, updatedBill.isPaid else { return }
        try await processBillPayment(for: updatedBill)
    }

    func markBillPaid(_ bill: Bill) async throws {
        var paidBill = bill
        paidBill.isPaid = true
        try await processBillPayment(for: paidBill)
    }

    /// The primary bridge between Bills and Account Ledger.
    func processBillPayment(for bill: Bill) async throws {
        guard let linkedAccountID = bill.linkedAccountID else { return }
        guard let client = database.client else { return }

        let params = BillPaymentRPCParams(
            billID: bill.id,
            accountID: linkedAccountID
        )
        try await client
            .rpc("process_bill_payment_atomic", params: params)
            .execute()

        if bill.recurrence.lowercased() != "none" {
            let nextBill = makeNextRecurringBill(from: bill)
            try await createBill(nextBill, client: client)
        }
    }

    private func createBill(_ bill: Bill, client: SupabaseClient) async throws {
        let payload = BillInsert(
            id: bill.id,
            name: bill.name,
            amount: bill.amount,
            dueDate: bill.dueDate,
            recurrence: bill.recurrence,
            category: bill.category,
            linkedAccountID: bill.linkedAccountID,
            isPaid: bill.isPaid
        )

        try await client
            .from("bills")
            .insert(payload)
            .execute()
    }

    private func makeNextRecurringBill(from bill: Bill) -> Bill {
        let nextDate = Calendar.current.date(byAdding: .month, value: 1, to: bill.dueDate) ?? bill.dueDate
        var next = bill
        next.id = UUID()
        next.dueDate = nextDate
        next.isPaid = false
        return next
    }
}

private struct BillPaymentRPCParams: Sendable {
    let billID: UUID
    let accountID: UUID

    enum CodingKeys: String, CodingKey {
        case billID = "p_bill_id"
        case accountID = "p_account_id"
    }
}

extension BillPaymentRPCParams: Encodable {
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(billID, forKey: .billID)
        try container.encode(accountID, forKey: .accountID)
    }
}

private struct BillInsert: Sendable {
    let id: UUID
    let name: String
    let amount: Decimal
    let dueDate: Date
    let recurrence: String
    let category: String
    let linkedAccountID: UUID?
    let isPaid: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case amount
        case dueDate = "due_date"
        case recurrence
        case category
        case linkedAccountID = "linked_account_id"
        case isPaid = "is_paid"
    }
}

extension BillInsert: Encodable {
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(amount, forKey: .amount)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(recurrence, forKey: .recurrence)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(linkedAccountID, forKey: .linkedAccountID)
        try container.encode(isPaid, forKey: .isPaid)
    }
}
