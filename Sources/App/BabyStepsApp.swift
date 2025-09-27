import SwiftData
import SwiftUI

@main
struct BabyStepsApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                LiquidGlassBackground()
                
                TabView {
                    TaskListView()
                        .tabItem {
                            Image(systemName: "list.bullet")
                            Text("タスク")
                        }

                    ActivityView()
                        .tabItem {
                            Image(systemName: "chart.bar.fill")
                            Text("アクティビティ")
                        }
                }
                .modelContainer(for: [Task.self, TaskStep.self])
                .onAppear {
                    print("🚀 BabyStepsApp起動")
                }
            }
        }
    }
}
