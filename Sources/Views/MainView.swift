import SwiftData
import SwiftUI

/// タブ切り替えを管理し、各ビューにボトムバーを委譲する。
struct MainView: View {
    @State private var selectedTab: AppTab = .tasks
    @State private var selectedFilter: TaskFilter = .all
    @State private var showingAddTask = false

    var body: some View {
        TabView(selection: $selectedTab) {
            TaskListView(
                selectedTab: $selectedTab,
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
                    ActivityView(selectedTab: $selectedTab)
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
    }
}
