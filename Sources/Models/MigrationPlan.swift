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
        willMigrate: { _ in },
        didMigrate: { context in
            // V1 に order がないため、コピー後に V2 の全 Task に createdAt 順で order を付与する。
            // SchemaV2.order のデフォルト 0 でコピーは成功するが、正しい並び順にするため。
            let descriptor = FetchDescriptor<SchemaV2.Task>(
                sortBy: [SortDescriptor(\.createdAt, order: .forward)]
            )
            let tasks = try context.fetch(descriptor)
            for (index, task) in tasks.enumerated() {
                task.order = index
            }
            try context.save()
        }
    )
}
