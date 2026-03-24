import SwiftUI

struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    HapticsService.tap(style: .medium)
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(selectedTab == tab ? Color.appPrimary : Color.secondary)
                            .frame(width: 28, height: 28)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(selectedTab == tab ? Color.black.opacity(0.06) : Color.clear)
                            )
                        Text(tab.title)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(selectedTab == tab ? Color.appPrimary : Color.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
        .shadow(color: .black.opacity(0.06), radius: 2, x: 0, y: 1)
    }
}
