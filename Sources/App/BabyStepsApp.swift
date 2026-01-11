import SwiftData
import SwiftUI

@main
struct BabyStepsApp: App {
    private enum AppTab: Hashable {
        case tasks
        case activity
    }

    @State private var selectedTab: AppTab = .tasks

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                TaskListView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("タスク")
                    }
                    .tag(AppTab.tasks)

                Group {
                    // 起動時のSwiftDataフェッチ/集計を避けるため、選択時にだけ生成する
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
            .modelContainer(for: [Task.self, TaskStep.self])
        }
    }
}
