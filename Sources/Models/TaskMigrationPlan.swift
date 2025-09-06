import Foundation
import SwiftData

/// Taskモデルのマイグレーションプラン
/// 既存のTaskデータにisCompletedとcompletedAtプロパティを安全に追加
enum TaskMigrationPlan: SchemaMigrationPlan {
    /// マイグレーション前のスキーマバージョン
    static var schemas: [any VersionedSchema.Type] {
        [TaskSchemaV1.self, TaskSchemaV2.self]
    }
    
    /// マイグレーション手順
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    /// V1からV2へのマイグレーション
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: TaskSchemaV1.self,
        toVersion: TaskSchemaV2.self,
        willMigrate: { context in
            print("🔄 Taskマイグレーション開始: V1 → V2")
            
            // 既存のTaskオブジェクトを取得
            let descriptor = FetchDescriptor<TaskV1>()
            let existingTasks = try? context.fetch(descriptor)
            
            print("🔄 既存タスク数: \(existingTasks?.count ?? 0)")
            
            // 各タスクに対して新しいプロパティを設定
            existingTasks?.forEach { oldTask in
                print("🔄 マイグレーション中: \(oldTask.title)")
                
                // 新しいTaskV2オブジェクトを作成
                let newTask = TaskV2(
                    id: oldTask.id,
                    title: oldTask.title,
                    createdAt: oldTask.createdAt,
                    steps: oldTask.steps,
                    isCompleted: false,  // デフォルトで未完了
                    completedAt: nil     // デフォルトでnil
                )
                
                // 既存のオブジェクトを削除
                context.delete(oldTask)
                
                // 新しいオブジェクトを挿入
                context.insert(newTask)
            }
            
            print("🔄 Taskマイグレーション完了")
        },
        didMigrate: { context in
            print("🔄 マイグレーション後の検証開始")
            
            // マイグレーション後のデータ整合性をチェック
            let descriptor = FetchDescriptor<TaskV2>()
            let migratedTasks = try? context.fetch(descriptor)
            
            print("🔄 マイグレーション後タスク数: \(migratedTasks?.count ?? 0)")
            
            // 各タスクのプロパティが正しく設定されているかチェック
            migratedTasks?.forEach { task in
                print("🔄 検証: \(task.title) - isCompleted: \(task.isCompleted), completedAt: \(task.completedAt?.description ?? "nil")")
            }
            
            print("🔄 マイグレーション検証完了")
        }
    )
}

// MARK: - Schema Versions

/// マイグレーション前のTaskスキーマ（V1）
@Model
final class TaskV1 {
    var id: UUID
    var title: String
    var createdAt: Date
    var steps: [TaskStep]
    
    init(id: UUID, title: String, createdAt: Date, steps: [TaskStep]) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.steps = steps
    }
}

/// マイグレーション後のTaskスキーマ（V2）
@Model
final class TaskV2 {
    var id: UUID
    var title: String
    var createdAt: Date
    var steps: [TaskStep]
    var isCompleted: Bool
    var completedAt: Date?
    
    init(id: UUID, title: String, createdAt: Date, steps: [TaskStep], isCompleted: Bool, completedAt: Date?) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.steps = steps
        self.isCompleted = isCompleted
        self.completedAt = completedAt
    }
}

// MARK: - Versioned Schemas

/// V1スキーマ定義
enum TaskSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [TaskV1.self, TaskStep.self]
    }
}

/// V2スキーマ定義
enum TaskSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [TaskV2.self, TaskStep.self]
    }
}