import Foundation

@MainActor
final class BillsViewModel: ObservableObject {
    @Published var bills: [Bill] = []
    @Published var isBitcoinMode = false
    @Published var btcPriceUSD: Double = 0
    @Published var coinDropTrigger = 0
    @Published private(set) var loadingBillIDs: Set<UUID> = []

    private let ledgerService: LedgerService
    private let coinGeckoService: CoinGeckoService
    private let motionManager: MotionManager

    init(
        ledgerService: LedgerService = LedgerService(),
        coinGeckoService: CoinGeckoService = CoinGeckoService(),
        motionManager: MotionManager = MotionManager()
    ) {
        self.ledgerService = ledgerService
        self.coinGeckoService = coinGeckoService
        self.motionManager = motionManager
        seedMockBills()
    }

    var paidBillsCount: Int {
        bills.filter(\.isPaid).count
    }

    var monthlyProgress: Double {
        guard !bills.isEmpty else { return 0 }
        return Double(paidBillsCount) / Double(bills.count)
    }

    var totalOutflow: Decimal {
        bills.reduce(0) { $0 + $1.amount }
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

    func markPaid(_ bill: Bill) {
        guard let index = bills.firstIndex(where: { $0.id == bill.id }) else { return }
        guard !loadingBillIDs.contains(bill.id), !bills[index].isPaid else { return }

        let previousIsPaid = bills[index].isPaid
        bills[index].isPaid = true
        loadingBillIDs.insert(bill.id)
        HapticsService.tap(style: .medium)

        let updatedBill = bills[index]
        Task {
            defer { loadingBillIDs.remove(bill.id) }
            do {
                try await ledgerService.syncBillPaymentToggle(
                    updatedBill: updatedBill,
                    previousIsPaid: previousIsPaid
                )
            } catch {
                if let rollbackIndex = bills.firstIndex(where: { $0.id == bill.id }) {
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
        bills = [
            Bill(id: UUID(), name: "Rent", amount: 1650, dueDate: .now, recurrence: "monthly", category: "Housing", linkedAccountID: accountID, isPaid: false),
            Bill(id: UUID(), name: "Electricity", amount: 120, dueDate: .now.addingTimeInterval(86_400 * 3), recurrence: "monthly", category: "Utilities", linkedAccountID: accountID, isPaid: false),
            Bill(id: UUID(), name: "Internet", amount: 85, dueDate: .now.addingTimeInterval(86_400 * 8), recurrence: "monthly", category: "Utilities", linkedAccountID: accountID, isPaid: true)
        ]
    }
}
