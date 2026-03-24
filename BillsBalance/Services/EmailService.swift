import Foundation
import PostgREST
import Supabase

final class EmailService {
    static let shared = EmailService()

    private let endpoint = URL(string: "https://api.resend.com/emails")!
    private let session: URLSession
    private let database: DatabaseManager
    private let apiKey: String
    private let fromEmail: String
    private let weeklySnapshotRecipient: String
    private let sentWeekKey = "email_service.weekly_snapshot.sent_week"
    private let userDefaults: UserDefaults

    init(
        session: URLSession = .shared,
        database: DatabaseManager = .shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.session = session
        self.database = database
        self.userDefaults = userDefaults
        self.apiKey = Configuration.resendAPIKey
        self.fromEmail = ProcessInfo.processInfo.environment["RESEND_FROM_EMAIL"] ?? "Bills & Balance <onboarding@resend.dev>"
        self.weeklySnapshotRecipient = ProcessInfo.processInfo.environment["WEEKLY_SNAPSHOT_TO_EMAIL"] ?? ""
    }

    func sendEmail(
        from: String,
        to: [String],
        subject: String,
        html: String
    ) async throws {
        guard !apiKey.isEmpty else {
            throw EmailServiceError.missingAPIKey
        }

        let payload = ResendEmailPayload(from: from, to: to, subject: subject, html: html)
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(payload)

        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw EmailServiceError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw EmailServiceError.requestFailed(statusCode: httpResponse.statusCode)
        }
    }

    /// Sends one weekly snapshot per calendar week on Sundays.
    func sendWeeklyFinancialSnapshotIfNeeded(now: Date = .now) async throws {
        guard isSunday(now) else { return }

        let weekIdentifier = weekKey(for: now)
        if userDefaults.string(forKey: sentWeekKey) == weekIdentifier {
            return
        }

        guard !weeklySnapshotRecipient.isEmpty else {
            throw EmailServiceError.missingSnapshotRecipient
        }

        let snapshot = try await buildWeeklySnapshot(referenceDate: now)
        try await sendWeeklyFinancialSnapshot(snapshot, recipient: weeklySnapshotRecipient)
        userDefaults.set(weekIdentifier, forKey: sentWeekKey)
    }

    private func sendWeeklyFinancialSnapshot(
        _ snapshot: WeeklyFinancialSnapshot,
        recipient: String
    ) async throws {
        let html = makeWeeklySnapshotHTML(snapshot)
        try await sendEmail(
            from: fromEmail,
            to: [recipient],
            subject: "Your Weekly Financial Snapshot",
            html: html
        )
    }

    private func buildWeeklySnapshot(referenceDate: Date) async throws -> WeeklyFinancialSnapshot {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: referenceDate)
        guard let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfDay) else {
            throw EmailServiceError.invalidDateRange
        }

        let dueDateFormatter = DateFormatter()
        dueDateFormatter.calendar = calendar
        dueDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dueDateFormatter.dateFormat = "yyyy-MM-dd"

        let startDateString = dueDateFormatter.string(from: startOfDay)
        let endDateString = dueDateFormatter.string(from: endOfWeek)

        guard let client = database.client else {
            throw EmailServiceError.supabaseNotConfigured
        }

        let dueBills: [WeeklyDueBillRow] = try await client
            .from("bills")
            .select("name, amount, due_date")
            .eq("is_paid", value: false)
            .gte("due_date", value: startDateString)
            .lte("due_date", value: endDateString)
            .order("due_date")
            .execute()
            .value

        let accountRows: [AccountBalanceRow] = try await client
            .from("accounts")
            .select("balance")
            .execute()
            .value

        let ledgerBalance = accountRows.reduce(Decimal.zero) { partialResult, account in
            partialResult + account.balance
        }

        return WeeklyFinancialSnapshot(
            dueBills: dueBills.map {
                WeeklyDueBill(name: $0.name, amount: $0.amount, dueDate: $0.dueDate)
            },
            currentLedgerBalance: ledgerBalance
        )
    }

    private func makeWeeklySnapshotHTML(_ snapshot: WeeklyFinancialSnapshot) -> String {
        let currency = CurrencyFormatter.usdString(from: snapshot.currentLedgerBalance)
        let billsList = snapshot.dueBills.isEmpty
            ? "<li>No bills due this week.</li>"
            : snapshot.dueBills.map { bill in
                "<li>\(escapeHTML(bill.name)) - \(CurrencyFormatter.usdString(from: bill.amount)) due \(escapeHTML(bill.dueDate))</li>"
            }.joined()

        return """
        <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; line-height: 1.5; color: #111827;">
          <h1 style="margin-bottom: 8px;">Weekly Financial Snapshot</h1>
          <p style="margin-top: 0;">Stay a few steps ahead this week.</p>
          <h2 style="margin-bottom: 6px;">Bills Due This Week</h2>
          <ul style="margin-top: 0;">\(billsList)</ul>
          <h2 style="margin-bottom: 6px;">Current Ledger Balance</h2>
          <p style="font-size: 20px; font-weight: 700; margin-top: 0;">\(currency)</p>
        </div>
        """
    }

    private func isSunday(_ date: Date) -> Bool {
        Calendar.current.component(.weekday, from: date) == 1
    }

    private func weekKey(for date: Date) -> String {
        let components = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return "\(components.yearForWeekOfYear ?? 0)-\(components.weekOfYear ?? 0)"
    }

    private func escapeHTML(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}

private struct ResendEmailPayload: Encodable {
    let from: String
    let to: [String]
    let subject: String
    let html: String
}

enum EmailServiceError: Error {
    case missingAPIKey
    case missingSnapshotRecipient
    case invalidDateRange
    case invalidResponse
    case requestFailed(statusCode: Int)
    case supabaseNotConfigured
}

private struct WeeklyDueBillRow: Decodable {
    let name: String
    let amount: Decimal
    let dueDate: String

    enum CodingKeys: String, CodingKey {
        case name
        case amount
        case dueDate = "due_date"
    }
}

private struct AccountBalanceRow: Decodable {
    let balance: Decimal
}

private struct WeeklyFinancialSnapshot {
    let dueBills: [WeeklyDueBill]
    let currentLedgerBalance: Decimal
}

private struct WeeklyDueBill {
    let name: String
    let amount: Decimal
    let dueDate: String
}

private enum CurrencyFormatter {
    static func usdString(from amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
}
