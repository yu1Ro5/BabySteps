import SwiftUI

/// タブバー用のタブボタン。TaskListView と ActivityView で共通利用。
struct TabBarButton: View {
    @Binding var selectedTab: AppTab
    let tab: AppTab
    let icon: String
    let label: String

    var body: some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                Text(label)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(selectedTab == tab ? Color.accentColor : Color.secondary)
        }
        .buttonStyle(.plain)
    }
}
