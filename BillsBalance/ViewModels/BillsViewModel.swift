import Combine
import Foundation
import UIKit

@MainActor
final class BillsViewModel: ObservableObject {
    @Published var bills: [Bill] = []
    @Published var isBitcoinMode = false
    @Published var btcPriceUSD: Double = 0
    @Published var coinDropTrigger = 0
    @Published private(set) var loadingBillIDs: Set<UUID> = []

    /// Bills scheduled beyond the current snapshot (mock count for UX reference).
    let futureBillsCount = 15

    private let ledgerService: LedgerService
    private let coinGeckoService: CoinGeckoService
    private let motionManager: MotionManager

    private static let paidToggleHaptic: UIImpactFeedbackGenerator = {
        let g = UIImpactFeedbackGenerator(style: .light)
        return g
    }()

    init(
        ledgerService: LedgerService,
        coinGeckoService: CoinGeckoService,
        motionManager: MotionManager
    ) {
        self.ledgerService = ledgerService
        self.coinGeckoService = coinGeckoService
        self.motionManager = motionManager
        seedMockBills()
    }

    convenience init() {
        self.init(
            ledgerService: LedgerService(),
            coinGeckoService: CoinGeckoService(),
            motionManager: MotionManager()
        )
    }

    var paidBillsCount: Int {
        bills.filter(\.isPaid).count
    }

    var unpaidBillsCount: Int {
        bills.filter { !$0.isPaid }.count
    }

    var overdueCount: Int {
        bills.filter { !$0.isPaid && $0.rowStatus() == .overdue }.count
    }

    var unpaidBillsSorted: [Bill] {
        bills.filter { !$0.isPaid }.sorted { $0.dueDate < $1.dueDate }
    }

    var monthlyProgress: Double {
        guard !bills.isEmpty else { return 0 }
        return Double(paidBillsCount) / Double(bills.count)
    }

    var snapshotTotalAmount: Decimal {
        bills.reduce(0) { $0 + $1.amount }
    }

    var remainingUnpaidAmount: Decimal {
        bills.filter { !$0.isPaid }.reduce(0) { $0 + $1.amount }
    }

    var snapshotMonthTitle: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: Date())
    }

    /// Next bill due (prefers upcoming on/after today; otherwise earliest unpaid).
    var nextDueBill: Bill? {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let unpaid = bills.filter { !$0.isPaid }
        let upcoming = unpaid
            .filter { cal.startOfDay(for: $0.dueDate) >= start }
            .sorted { $0.dueDate < $1.dueDate }
        if let first = upcoming.first { return first }
        return unpaid.sorted { $0.dueDate < $1.dueDate }.first
    }

    func toggleBitcoinMode() {
        isBitcoinMode.toggle()
        HapticsService.tap(style: .heavy)
        coinDropTrigger += 1
    }

    func startShakeDetection() {
        motionManager.start { [weak self] in
            Task { @MainActor in
                self?.toggleBitcoinMode()
            }
        }
    }

    func stopShakeDetection() {
        motionManager.stop()
    }

    func fetchBTCPrice() async {
        do {
            btcPriceUSD = try await coinGeckoService.fetchBTCPriceUSD()
        } catch {
            btcPriceUSD = 0
        }
    }

    func satsDisplay(for bill: Bill) -> String {
        guard btcPriceUSD > 0 else { return "-- sats" }
        let amount = NSDecimalNumber(decimal: bill.amount).doubleValue
        let sats = coinGeckoService.usdToSats(usd: amount, btcPriceUSD: btcPriceUSD)
        return "\(sats) sats"
    }

    func isMarkPaidLoading(for bill: Bill) -> Bool {
        loadingBillIDs.contains(bill.id)
    }

    func setPaid(_ bill: Bill, isPaid: Bool) {
        guard let index = bills.firstIndex(where: { $0.id == bill.id }) else { return }
        if isPaid {
            guard !bills[index].isPaid, !loadingBillIDs.contains(bill.id) else { return }
            markPaidAfterChecks(at: index)
        } else {
            guard bills[index].isPaid else { return }
            bills[index].isPaid = false
            Self.paidToggleHaptic.prepare()
            Self.paidToggleHaptic.impactOccurred()
        }
    }

    func markPaid(_ bill: Bill) {
        guard let index = bills.firstIndex(where: { $0.id == bill.id }) else { return }
        guard !bills[index].isPaid, !loadingBillIDs.contains(bill.id) else { return }
        markPaidAfterChecks(at: index)
    }

    private func markPaidAfterChecks(at index: Int) {
        let previousIsPaid = bills[index].isPaid
        bills[index].isPaid = true
        loadingBillIDs.insert(bills[index].id)
        Self.paidToggleHaptic.prepare()
        Self.paidToggleHaptic.impactOccurred()

        let updatedBill = bills[index]
        Task {
            defer { loadingBillIDs.remove(updatedBill.id) }
            do {
                try await ledgerService.syncBillPaymentToggle(
                    updatedBill: updatedBill,
                    previousIsPaid: previousIsPaid
                )
            } catch {
                if let rollbackIndex = bills.firstIndex(where: { $0.id == updatedBill.id }) {
                    bills[rollbackIndex].isPaid = previousIsPaid
                }
            }
        }
    }

    func delete(_ bill: Bill) {
        bills.removeAll { $0.id == bill.id }
        HapticsService.tap(style: .light)
    }

    private func seedMockBills() {
        let accountID = UUID()
        let cal = Calendar.current
        let today = Date()

        let canvaDue = cal.date(byAdding: .day, value: -4, to: today)!
        let icloudDue = cal.date(byAdding: .day, value: 3, to: today)!
        let progressiveDue = cal.date(byAdding: .day, value: 8, to: today)!

        var list: [Bill] = [
            Bill(
                id: UUID(),
                name: "Canva",
                amount: 15,
                dueDate: canvaDue,
                recurrence: "monthly",
                category: "Design",
                paymentMethod: "Apple Card",
                linkedAccountID: accountID,
                isPaid: false,
                isAutoPay: true
            ),
            Bill(
                id: UUID(),
                name: "iCloud",
                amount: 9.99,
                dueDate: icloudDue,
                recurrence: "monthly",
                category: "Cloud",
                paymentMethod: "Apple Card",
                linkedAccountID: accountID,
                isPaid: false,
                isAutoPay: true
            ),
            Bill(
                id: UUID(),
                name: "Progressive Auto",
                amount: 300,
                dueDate: progressiveDue,
                recurrence: "semi-annually",
                category: "Insurance",
                paymentMethod: "Apple Card",
                linkedAccountID: accountID,
                isPaid: false,
                isAutoPay: false
            )
        ]

        for i in 0 ..< 11 {
            let due = cal.date(byAdding: .day, value: -20 - i, to: today)!
            let amount: Decimal = i == 10 ? 41.76 : 37
            list.append(
                Bill(
                    id: UUID(),
                    name: "Paid \(i + 1)",
                    amount: amount,
                    dueDate: due,
                    recurrence: "monthly",
                    category: "Utilities",
                    paymentMethod: "Apple Card",
                    linkedAccountID: accountID,
                    isPaid: true,
                    isAutoPay: false
                )
            )
        }

        bills = list
    }
}
