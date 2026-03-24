import SwiftUI

struct SnapshotCard: View {
    let monthTitle: String
    let totalAmount: Decimal
    let remainingAmount: Decimal
    let progress: Double
    let paidCount: Int
    let totalCount: Int
    let unpaidCount: Int
    let overdueCount: Int
    let nextDueBill: Bill?
    let isBitcoinMode: Bool

    private var fillGradient: LinearGradient {
        LinearGradient(
            colors: isBitcoinMode
                ? [.orange, .yellow]
                : [Color.billStatusPaid, Color(red: 0.35, green: 0.88, blue: 0.52)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(monthTitle)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text("Monthly Snapshot")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.primary)
                }
                Spacer(minLength: 12)
                VStack(alignment: .trailing, spacing: 6) {
                    Text("\(paidCount) of \(totalCount) paid")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    GeometryReader { proxy in
                        let fillWidth = max(0, min(1, progress)) * proxy.size.width
                        let barHeight: CGFloat = 12
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.black.opacity(0.08))
                                .frame(height: barHeight)

                            if fillWidth > 0.5 {
                                Capsule()
                                    .fill(fillGradient)
                                    .frame(width: fillWidth, height: barHeight)
                                    .blur(radius: 4)
                                    .opacity(0.9)

                                Capsule()
                                    .fill(fillGradient)
                                    .frame(width: fillWidth, height: barHeight)
                                    .shadow(color: isBitcoinMode ? Color.orange.opacity(0.3) : Color.green.opacity(0.3), radius: 8)
                            }
                        }
                    }
                    .frame(width: 120, height: 12)
                }
            }

            Text(totalAmount, format: .currency(code: "USD"))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .padding(.top, 12)

            Text("Remaining: \(remainingAmount, format: .currency(code: "USD"))")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.top, 4)

            HStack(spacing: 8) {
                snapshotPill(text: "\(unpaidCount) Unpaid", fg: .billStatusUpcoming, bg: Color.snapshotPillBlueBG)
                snapshotPill(text: "\(overdueCount) Overdue", fg: .billStatusOverdue, bg: Color.snapshotPillRedBG)
                snapshotPill(text: "\(paidCount) Paid", fg: Color(red: 0.12, green: 0.55, blue: 0.22), bg: Color.snapshotPillGreenBG)
            }
            .padding(.top, 14)

            if let next = nextDueBill {
                HStack(spacing: 6) {
                    Text("Next Due")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text("•")
                        .foregroundStyle(.tertiary)
                    Text("\(next.name) • \(next.dueDate.formatted(.dateTime.month(.abbreviated).day()))")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                .padding(.top, 16)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .standardCard()
        .accessibilityElement(children: .combine)
    }

    private func snapshotPill(text: String, fg: Color, bg: Color) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(fg)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(bg, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
