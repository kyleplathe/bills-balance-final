import SwiftUI

struct BillsView: View {
    @ObservedObject var viewModel: BillsViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SnapshotCard(
                        progress: viewModel.monthlyProgress,
                        paidCount: viewModel.paidBillsCount,
                        totalCount: viewModel.bills.count,
                        totalOutflow: viewModel.totalOutflow,
                        isBitcoinMode: viewModel.isBitcoinMode
                    )

                    Button {
                        viewModel.toggleBitcoinMode()
                    } label: {
                        Label(viewModel.isBitcoinMode ? "Bitcoin Mode Enabled" : "Shake for Bitcoin", systemImage: "bitcoinsign.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(viewModel.isBitcoinMode ? Color.orange : Color.appPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Toggle Bitcoin mode")

                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.bills) { bill in
                            BillCard(
                                bill: bill,
                                isBitcoinMode: viewModel.isBitcoinMode,
                                satsLabel: viewModel.satsDisplay(for: bill)
                            )
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
                            .contextMenu {
                                Button("Edit this only", systemImage: "square.and.pencil") {}
                                Button("Edit all future", systemImage: "square.stack.3d.up.fill") {}
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 140)
            }
            .background(Color.appBackground)
            .navigationTitle("Bills")
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
