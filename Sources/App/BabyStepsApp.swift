import Foundation
import SwiftData
import SwiftUI

/// アプリのメインタブ種別
enum AppTab: Hashable {
    case tasks
    case activity
}

private let appGroupID = "group.com.yu1Ro5.BabySteps"
private let storeFileName = "default.store"

@main
struct BabyStepsApp: App {
    private let modelContainer: ModelContainer = {
        let schema = Schema(versionedSchema: SchemaLatest.self)

        if Self.isRunningTests {
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(
                    for: schema,
                    migrationPlan: BabyStepsMigrationPlan.self,
                    configurations: [config]
                )
            }
            catch {
                fatalError("Could not create test ModelContainer: \(error)")
            }
        }

        let appSupportURL = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let legacyURL = appSupportURL.appendingPathComponent(storeFileName)
        let appGroupContainer = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
        let targetURL = appGroupContainer?
            .appendingPathComponent(storeFileName) ?? legacyURL

        Self.migrateStoreIfNeeded(from: legacyURL, to: targetURL, appGroupContainer: appGroupContainer)

        let config = ModelConfiguration(schema: schema, url: targetURL)

        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: BabyStepsMigrationPlan.self,
                configurations: [config]
            )
        }
        catch {
            Self.removeStoreFiles(at: targetURL)
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

    /// 既存の Application Support ストアを App Group コンテナへ移行する（初回のみ）
    private static func migrateStoreIfNeeded(from legacyURL: URL, to targetURL: URL, appGroupContainer: URL?) {
        guard let container = appGroupContainer else { return }
        guard legacyURL != targetURL else { return }

        let targetStore = container.appendingPathComponent(storeFileName)
        let legacyExists = FileManager.default.fileExists(atPath: legacyURL.path)
        let targetExists = FileManager.default.fileExists(atPath: targetStore.path)

        if legacyExists, !targetExists {
            try? FileManager.default.createDirectory(at: container, withIntermediateDirectories: true)
            try? FileManager.default.copyItem(at: legacyURL, to: targetStore)
            try? FileManager.default.copyItem(atPath: legacyURL.path + "-wal", toPath: targetStore.path + "-wal")
            try? FileManager.default.copyItem(atPath: legacyURL.path + "-shm", toPath: targetStore.path + "-shm")
            removeStoreFiles(at: legacyURL)
        }
    }

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
