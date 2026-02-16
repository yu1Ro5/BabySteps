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
                .modelContainer(for: [Task.self, TaskStep.self], inMemory: isRunningTests)
        }
    }

    /// XCTest 実行中は true。テスト時はメモリ内ストアを使用し、CoreData のディスクアクセスエラーを回避する。
    private var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
