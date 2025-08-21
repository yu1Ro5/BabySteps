import SwiftUI
import SwiftData

@main
struct BabyStepsApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                TaskListView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("タスク")
                    }
                    .modelContainer(for: [Task.self, TaskStep.self])
                
                SecondTabView()
                    .tabItem {
                        Image(systemName: "star")
                        Text("機能予定")
                    }
            }
        }
    }
}
