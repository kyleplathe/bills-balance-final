import SwiftUI

struct RootView: View {
    @State private var selectedTab: AppTab = .bills
    @StateObject private var billsViewModel = BillsViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .bills:
                    BillsView(viewModel: billsViewModel)
                case .balance:
                    BalanceView()
                case .calendar:
                    CalendarView()
                }
            }
            .padding(.bottom, 94)

            FloatingTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 22)
                .padding(.bottom, 20)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .task {
            do {
                try await EmailService.shared.sendWeeklyFinancialSnapshotIfNeeded()
            } catch {
                // Keep UI resilient if email transport/configuration is unavailable.
            }
        }
    }
}

enum AppTab: String, CaseIterable {
    case bills
    case balance
    case calendar

    var title: String {
        switch self {
        case .bills:
            return "Bills"
        case .balance:
            return "Balance"
        case .calendar:
            return "Calendar"
        }
    }

    var icon: String {
        switch self {
        case .bills:
            return "doc.text.fill"
        case .balance:
            return "square.grid.2x2.fill"
        case .calendar:
            return "calendar"
        }
    }
}
