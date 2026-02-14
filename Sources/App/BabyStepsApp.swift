import SwiftData
import SwiftUI

@main
struct BabyStepsApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(for: [Task.self, TaskStep.self])
        }
    }
}
