import SwiftData
import SwiftUI

/// ネイティブ TabView でタブ切り替えを管理する。
struct MainView: View {
    @State private var selectedTab: AppTab = .tasks
    @State private var selectedFilter: TaskFilter = .all

    var body: some View {
        TabView(selection: $selectedTab) {
            TaskListView(
                selectedFilter: $selectedFilter
            )
            .tabItem {
                Image(systemName: "list.bullet")
                Text("タスク")
            }
            .tag(AppTab.tasks)

            ActivityView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("アクティビティ")
                }
                .tag(AppTab.activity)
        }
    }
}
