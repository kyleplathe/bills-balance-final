import SwiftUI

struct BillCard: View {
    let bill: Bill
    let isBitcoinMode: Bool
    let satsLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bill.name)
                        .font(.headline.weight(.semibold))
                    Text(bill.category)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(bill.amount, format: .currency(code: "USD"))
                    .font(.headline.weight(.bold))
            }

            HStack {
                Label(bill.dueDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                    .font(.caption.weight(.medium))

                Spacer()

                if isBitcoinMode {
                    Text(satsLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                }

                Text(bill.isPaid ? "Cleared" : "Pending")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(bill.isPaid ? .green : .yellow)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(bill.name), amount \(bill.amount as NSDecimalNumber) dollars, due \(bill.dueDate.formatted(date: .abbreviated, time: .omitted)), \(bill.isPaid ? "cleared" : "pending").")
    }
}
