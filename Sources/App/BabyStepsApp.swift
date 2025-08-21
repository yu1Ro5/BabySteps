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
                
                ActivityView(modelContext: ModelContext(try! ModelContainer(for: Task.self, TaskStep.self)))
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("アクティビティ")
                    }
            }
            .modelContainer(for: [Task.self, TaskStep.self])
        }
    }
}
