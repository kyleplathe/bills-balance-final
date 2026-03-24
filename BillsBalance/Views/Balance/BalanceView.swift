import SwiftUI

struct BalanceView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(0..<6, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Account \(index + 1)")
                                .font(.subheadline.weight(.semibold))
                            Text("$0.00")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Color.appPrimary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
                        .padding()
                        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.black.opacity(0.06), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
                    }
                }
                .padding(20)
            }
            .background(Color.appBackground)
            .navigationTitle("Balance")
        }
    }
}
