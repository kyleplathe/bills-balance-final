import SwiftUI

struct CoinRainOverlay: View {
    let trigger: Int
    private let coinCount = 18
    @State private var animateDrop = false
    @State private var horizontalOffsets: [CGFloat] = []
    @State private var iconSizes: [CGFloat] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(Array(horizontalOffsets.enumerated()), id: \.offset) { index, xOffset in
                    Image(systemName: "bitcoinsign.circle.fill")
                        .font(.system(size: iconSizes[index], weight: .bold))
                        .foregroundStyle(.orange)
                        .offset(
                            x: xOffset,
                            y: animateDrop ? geo.size.height + 40 : -40
                        )
                        .opacity(animateDrop ? 0.95 : 0)
                        .animation(
                            .spring(duration: 0.9, bounce: 0.18).delay(Double(index) * 0.03),
                            value: animateDrop
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 190)
        .onAppear {
            resetOffsets()
        }
        .onChange(of: trigger) {
            resetOffsets()
            animateDrop = false
            withAnimation {
                animateDrop = true
            }
        }
    }

    private func resetOffsets() {
        horizontalOffsets = (0..<coinCount).map { _ in CGFloat.random(in: -170...170) }
        iconSizes = (0..<coinCount).map { _ in CGFloat.random(in: 16...30) }
    }
}
