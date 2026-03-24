import SwiftUI

struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab

    private let innerInset = Theme.navBarInnerInset

    var body: some View {
        GeometryReader { geo in
            let count = CGFloat(AppTab.allCases.count)
            let tabWidth = geo.size.width / count
            let index = CGFloat(AppTab.allCases.firstIndex(of: selectedTab) ?? 0)
            let pillWidth = max(0, tabWidth - innerInset * 2)
            let pillHeight = max(0, geo.size.height - innerInset * 2)
            let pillX = index * tabWidth + innerInset

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.thinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.38), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                    .frame(width: pillWidth, height: pillHeight)
                    .offset(x: pillX)
                    .animation(.spring(response: 0.4, dampingFraction: 0.78), value: selectedTab)

                HStack(spacing: 0) {
                    ForEach(AppTab.allCases, id: \.self) { tab in
                        tabItem(tab: tab)
                            .frame(width: tabWidth)
                    }
                }
            }
        }
        .frame(height: 56)
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .liquidGlassCapsuleNavBar()
    }

    @ViewBuilder
    private func tabItem(tab: AppTab) -> some View {
        Button {
            HapticsService.tap(style: .medium)
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(selectedTab == tab ? Color.appPrimary : Color.secondary)
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 28, height: 28)
                Text(tab.title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(selectedTab == tab ? Color.appPrimary : Color.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(selectedTab == tab ? [.isSelected] : [])
    }
}
