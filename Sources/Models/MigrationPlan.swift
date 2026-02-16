import Foundation
import SwiftData

enum BabyStepsMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: SchemaV1.self,
        toVersion: SchemaV2.self,
        willMigrate: { context in
            // マイグレーション前に V1 の全 Task に order を付与する。
            // order が nil のまま V2（必須）にコピーすると検証エラーになるため。
            let descriptor = FetchDescriptor<SchemaV1.Task>(
                sortBy: [SortDescriptor(\.createdAt, order: .forward)]
            )
            let tasks = try context.fetch(descriptor)
            for (index, task) in tasks.enumerated() {
                task.order = index
            }
            try context.save()
        },
        didMigrate: { _ in }
    )
}
