import SwiftData
import SwiftUI

/// メールアプリ風レイアウト：左下にフィルター、下にタブバー、右下にプラスボタン。
struct MainView: View {
    private enum AppTab: Hashable {
        case tasks
        case activity
    }

    @State private var selectedTab: AppTab = .tasks
    @State private var selectedFilter: TaskFilter = .all
    @State private var showingAddTask = false
    var body: some View {
        TabView(selection: $selectedTab) {
            TaskListView(
                selectedFilter: $selectedFilter,
                showingAddTask: $showingAddTask
            )
            .tabItem {
                Image(systemName: "list.bullet")
                Text("タスク")
            }
            .tag(AppTab.tasks)

            Group {
                if selectedTab == .activity {
                    ActivityView()
                }
                else {
                    Color.clear
                }
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("アクティビティ")
            }
            .tag(AppTab.activity)
        }
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom) {
            customBottomBar
        }
    }

    /// メールアプリ風のカスタムボトムバー：左下フィルター、中央タブ、右下プラス。
    private var customBottomBar: some View {
        HStack(spacing: 0) {
            // 左下：フィルターボタン（タスクタブ時のみ）
            if selectedTab == .tasks {
                Menu {
                    Picker("フィルター", selection: $selectedFilter) {
                        ForEach(TaskFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.title2)
                }
                .frame(width: 44, height: 44)
            }

            Spacer()

            // 中央：タブ切り替え
            HStack(spacing: 0) {
                tabButton(tab: .tasks, icon: "list.bullet", label: "タスク")
                tabButton(tab: .activity, icon: "chart.bar.fill", label: "アクティビティ")
            }

            Spacer()

            // 右下：プラスボタン（タスクタブ時のみ）
            if selectedTab == .tasks {
                Button(action: { showingAddTask = true }) {
                    Image(systemName: "square.and.pencil")
                        .font(.title2)
                }
                .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(.bar)
    }

    private func tabButton(tab: AppTab, icon: String, label: String) -> some View {
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
