import SwiftUI
import UIKit

struct BillsView: View {
    @ObservedObject var viewModel: BillsViewModel

    private var unpaid: [Bill] {
        viewModel.unpaidBillsSorted
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        SnapshotCard(
                            monthTitle: viewModel.snapshotMonthTitle,
                            totalAmount: viewModel.snapshotTotalAmount,
                            remainingAmount: viewModel.remainingUnpaidAmount,
                            progress: viewModel.monthlyProgress,
                            paidCount: viewModel.paidBillsCount,
                            totalCount: viewModel.bills.count,
                            unpaidCount: viewModel.unpaidBillsCount,
                            overdueCount: viewModel.overdueCount,
                            nextDueBill: viewModel.nextDueBill,
                            isBitcoinMode: viewModel.isBitcoinMode
                        )

                        HStack {
                            Text(viewModel.snapshotMonthTitle)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("\(unpaid.count) bills")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 4)

                        VStack(spacing: 16) {
                            ForEach(unpaid) { bill in
                                BillCard(
                                    bill: bill,
                                    isBitcoinMode: viewModel.isBitcoinMode,
                                    satsLabel: viewModel.satsDisplay(for: bill),
                                    isMarkPaidLoading: viewModel.isMarkPaidLoading(for: bill),
                                    onPaidChange: { viewModel.setPaid(bill, isPaid: $0) }
                                )
                                .standardCard()
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button {
                                        viewModel.markPaid(bill)
                                    } label: {
                                        if viewModel.isMarkPaidLoading(for: bill) {
                                            Label("Loading", systemImage: "hourglass")
                                        } else {
                                            Label("Mark Paid", systemImage: "checkmark.circle.fill")
                                        }
                                    }
                                    .tint(.green)
                                    .disabled(viewModel.isMarkPaidLoading(for: bill))
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.delete(bill)
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                }
                            }
                        }

                        Button {
                            // Placeholder: future bills list
                        } label: {
                            HStack {
                                Text("Future bills")
                                    .font(.body.weight(.semibold))
                                Spacer()
                                Text("\(viewModel.futureBillsCount) bills")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.secondary)
                                Image(systemName: "chevron.right")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(16)
                            .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 150)
                }
            }
            .background(BillsNavigationBarTitleStyle())
            .navigationTitle("Bills")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 4) {
                        Button {
                            // Add bill
                        } label: {
                            Image(systemName: "plus")
                                .font(.body.weight(.semibold))
                        }
                        Button {
                            // Search
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.body.weight(.semibold))
                        }
                        Menu {
                            Button("Shake for Bitcoin", systemImage: "bitcoinsign.circle.fill") {
                                viewModel.toggleBitcoinMode()
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.body.weight(.semibold))
                        }
                    }
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.cardBackground, in: Capsule())
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
                }
            }
            .overlay(alignment: .top) {
                CoinRainOverlay(trigger: viewModel.coinDropTrigger)
                    .allowsHitTesting(false)
            }
        }
        .task {
            await viewModel.fetchBTCPrice()
            viewModel.startShakeDetection()
        }
        .onDisappear {
            viewModel.stopShakeDetection()
        }
    }
}

// Applies a bold large title and transparent bar styling to the hosting navigation controller.
private struct BillsNavigationBarTitleStyle: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            guard let nav = uiViewController.nearestNavigationController() else { return }
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.largeTitleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 34, weight: .bold)
            ]
            nav.navigationBar.standardAppearance = appearance
            nav.navigationBar.scrollEdgeAppearance = appearance
            nav.navigationBar.compactAppearance = appearance
        }
    }
}

private extension UIViewController {
    func nearestNavigationController() -> UINavigationController? {
        if let nav = navigationController { return nav }
        var ancestor: UIViewController? = parent
        while let vc = ancestor {
            if let nav = vc.navigationController { return nav }
            if let nav = vc as? UINavigationController { return nav }
            ancestor = vc.parent
        }
        return nil
    }
}
