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
                    }
                }
                .padding(20)
            }
            .background(Color.appBackground)
            .navigationTitle("Balance")
        }
    }
}
