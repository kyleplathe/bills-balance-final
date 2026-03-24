import SwiftUI

struct Theme {
    // The off-white base that makes cards "pop"
    static let background = Color(red: 0.96, green: 0.97, blue: 0.98)
    
    // Card styling
    static let cardCornerRadius: CGFloat = 24
    static let cardShadow = ShadowConfig(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 8)
    
    // Liquid Glass settings
    static let glassOpacity: Double = 0.7
    static let glassBlur: CGFloat = 15
    
    struct ShadowConfig {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

extension View {
    func liquidGlassCard() -> some View {
        self.padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .stroke(.white.opacity(0.4), lineWidth: 0.5)
            )
            .shadow(color: Theme.cardShadow.color, radius: Theme.cardShadow.radius, x: Theme.cardShadow.x, y: Theme.cardShadow.y)
    }
    
    func standardCard() -> some View {
        self.padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
            .shadow(color: Theme.cardShadow.color, radius: Theme.cardShadow.radius, x: Theme.cardShadow.x, y: Theme.cardShadow.y)
    }
}