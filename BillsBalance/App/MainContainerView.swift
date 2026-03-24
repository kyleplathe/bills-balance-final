import SwiftUI

struct MainContainerView: View {
    @State private var selectedTab: AppTab = .bills
    @StateObject private var billsViewModel = BillsViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                BillsView(viewModel: billsViewModel)
                    .opacity(selectedTab == .bills ? 1 : 0)
                    .allowsHitTesting(selectedTab == .bills)

                BalanceView()
                    .opacity(selectedTab == .balance ? 1 : 0)
                    .allowsHitTesting(selectedTab == .balance)

                CalendarView()
                    .opacity(selectedTab == .calendar ? 1 : 0)
                    .allowsHitTesting(selectedTab == .calendar)

                Text("Hello World")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 12)
                    .allowsHitTesting(false)
            }
            .animation(.easeInOut(duration: 0.22), value: selectedTab)
            .padding(.bottom, 108)

            FloatingTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 22)
                .padding(.bottom, 20)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .fontDesign(.rounded)
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
            return "list.bullet.below.rectangle"
        case .balance:
            return "creditcard.fill"
        case .calendar:
            return "calendar"
        }
    }
}

#Preview {
    MainContainerView()
}
