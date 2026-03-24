import SwiftUI

struct CalendarView: View {
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                if proxy.size.width > proxy.size.height {
                    HStack(spacing: 0) {
                        calendarGrid
                            .frame(maxWidth: .infinity)
                        Divider()
                        dayDetails
                            .frame(maxWidth: .infinity)
                    }
                } else {
                    calendarGrid
                }
            }
            .padding(16)
            .background(Color.appBackground)
            .navigationTitle("Calendar")
        }
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(1...35, id: \.self) { day in
                VStack(spacing: 6) {
                    Text("\(day)")
                        .font(.caption.weight(.semibold))
                    Circle()
                        .fill(day % 3 == 0 ? Color.red : (day % 2 == 0 ? Color.yellow : Color.green))
                        .frame(width: 6, height: 6)
                }
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.vertical, 6)
                .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
            }
        }
    }

    private var dayDetails: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Day Details")
                .font(.title3.weight(.bold))
            Text("Select a date to view due bills, outflow, and ledger entries.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
    }
}
