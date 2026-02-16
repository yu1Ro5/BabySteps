import SwiftData
import SwiftUI

/// アプリのメインタブ種別
enum AppTab: Hashable {
    case tasks
    case activity
}

@main
struct BabyStepsApp: App {
    private let modelContainer: ModelContainer = {
        let schema = Schema(versionedSchema: SchemaLatest.self)
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: Self.isRunningTests
        )
        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: BabyStepsMigrationPlan.self,
                configurations: [config]
            )
        }
        catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(modelContainer)
        }
    }

    /// XCTest 実行中は true。テスト時はメモリ内ストアを使用し、CoreData のディスクアクセスエラーを回避する。
    private static var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
