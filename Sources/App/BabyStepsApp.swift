import Foundation
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
        let storeURL = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("default.store")
        let config: ModelConfiguration = Self.isRunningTests
            ? ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            : ModelConfiguration(schema: schema, url: storeURL)

        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: BabyStepsMigrationPlan.self,
                configurations: [config]
            )
        }
        catch {
            // 最終手段: マイグレーション失敗時にストアを削除して再試行。
            // データは失われるが、クラッシュは防ぐ。通常は SchemaV1（order なし）と
            // SchemaV2（order デフォルト）でマイグレーションが成功する想定。
            guard !Self.isRunningTests else {
                fatalError("Could not create ModelContainer: \(error)")
            }
            Self.removeStoreFiles(at: storeURL)
            do {
                return try ModelContainer(
                    for: schema,
                    migrationPlan: BabyStepsMigrationPlan.self,
                    configurations: [config]
                )
            }
            catch let err {
                fatalError("Could not create ModelContainer: \(err)")
            }
        }
    }()

    /// ストアファイル（.store, .store-wal, .store-shm）を削除する
    private static func removeStoreFiles(at url: URL) {
        let fm = FileManager.default
        try? fm.removeItem(at: url)
        let path = url.path
        try? fm.removeItem(atPath: path + "-wal")
        try? fm.removeItem(atPath: path + "-shm")
    }

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
