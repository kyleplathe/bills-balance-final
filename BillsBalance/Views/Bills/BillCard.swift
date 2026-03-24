import SwiftUI

struct BillCard: View {
    let bill: Bill
    let isBitcoinMode: Bool
    let satsLabel: String
    var isMarkPaidLoading: Bool = false
    var onPaidChange: (Bool) -> Void

    private var status: Bill.RowStatus {
        bill.rowStatus()
    }

    private var ringColor: Color {
        switch status {
        case .paid:
            return .billStatusPaid
        case .upcoming:
            return .billStatusUpcoming
        case .dueSoon:
            return .billStatusDueSoon
        case .overdue:
            return .billStatusOverdue
        }
    }

    private func relativeDuePhrase() -> String {
        let d = bill.daysOffsetFromToday()
        if d < 0 {
            return "\(abs(d))d overdue"
        }
        return "\(d)d left"
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Button {
                if !bill.isPaid {
                    onPaidChange(true)
                } else {
                    onPaidChange(false)
                }
            } label: {
                ZStack {
                    if bill.isPaid {
                        Circle()
                            .fill(Color.billStatusPaid.opacity(0.2))
                            .frame(width: 44, height: 44)
                        Circle()
                            .stroke(Color.billStatusPaid, lineWidth: 2.5)
                            .frame(width: 44, height: 44)
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.billStatusPaid)
                    } else {
                        Circle()
                            .stroke(ringColor, lineWidth: 2.5)
                            .frame(width: 44, height: 44)
                    }
                }
                .opacity(isMarkPaidLoading ? 0.45 : 1)
            }
            .buttonStyle(.plain)
            .disabled(isMarkPaidLoading)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text(bill.name)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                    if bill.isAutoPay {
                        Image(systemName: "bolt.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.orange)
                    }
                }

                HStack(spacing: 4) {
                    Image(systemName: "creditcard.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(bill.paymentMethod)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text("•")
                        .foregroundStyle(.tertiary)
                    Text(bill.dueDate.formatted(.dateTime.month(.abbreviated).day()))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text("•")
                        .foregroundStyle(.tertiary)
                    Text(relativeDuePhrase())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(relativeDueColor())
                    Text("•")
                        .foregroundStyle(.tertiary)
                    Text(bill.recurrenceLabel)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                if isBitcoinMode {
                    Text(satsLabel)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.orange)
                }
            }

            Spacer(minLength: 8)

            Text(bill.amount, format: .currency(code: "USD"))
                .font(.body.weight(.bold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(bill.name), \(bill.amount as NSDecimalNumber) dollars, \(relativeDuePhrase())")
    }

    private func relativeDueColor() -> Color {
        switch status {
        case .overdue:
            return .billStatusOverdue
        case .dueSoon:
            return .billStatusDueSoon
        default:
            return .secondary
        }
    }
}
