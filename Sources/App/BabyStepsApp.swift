import SwiftData
import SwiftUI

/// アプリのメインタブ種別
enum AppTab: Hashable {
    case tasks
    case activity
}

@main
struct BabyStepsApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(for: [Task.self, TaskStep.self])
        }
    }
}
