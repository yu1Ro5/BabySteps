import SwiftUI
import SwiftData

@main
struct BabyStepsApp: App {
    var body: some Scene {
        WindowGroup {
            TaskListView()
                .modelContainer(for: [Task.self, TaskStep.self])
        }
    }
}
