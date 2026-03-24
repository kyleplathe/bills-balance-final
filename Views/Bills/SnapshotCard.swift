import SwiftUI

struct SnapshotCard: View {
    let progress: Double
    let paidCount: Int
    let totalCount: Int
    let totalOutflow: Decimal
    let isBitcoinMode: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Monthly Snapshot")
                .font(.headline.weight(.bold))

            VStack(alignment: .leading, spacing: 8) {
                Text("\(paidCount) of \(totalCount) paid")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 12)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: isBitcoinMode ? [.orange, .yellow] : [.cyan, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: proxy.size.width * max(0.05, progress), height: 12)
                            .shadow(color: (isBitcoinMode ? Color.orange : Color.blue).opacity(0.8), radius: 12)
                    }
                }
                .frame(height: 12)
            }

            Text("Outflow: \(totalOutflow, format: .currency(code: "USD"))")
                .font(.subheadline.weight(.bold))
        }
        .foregroundStyle(.white)
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color.appPrimary, Color.appPrimary.opacity(0.74)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Monthly Snapshot. \(paidCount) of \(totalCount) bills paid. Outflow \(totalOutflow as NSDecimalNumber) dollars.")
    }
}
