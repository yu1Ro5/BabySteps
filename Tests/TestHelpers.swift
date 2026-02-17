import Foundation
import SwiftData
@testable import BabySteps

enum TestHelpers {
    static func makeInMemoryContainer() throws -> ModelContainer {
        let schema = Schema(versionedSchema: SchemaLatest.self)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: schema,
            migrationPlan: BabyStepsMigrationPlan.self,
            configurations: [config]
        )
    }

    /// Creates a file-based store with SchemaV1 only (no migration plan).
    /// Used to seed data for migration tests. Caller must delete the directory when done.
    static func makeV1Store(at url: URL) throws -> ModelContainer {
        let schema = Schema(versionedSchema: SchemaV1.self)
        let config = ModelConfiguration(url: url)
        return try ModelContainer(for: schema, configurations: [config])
    }

    /// Opens an existing store with MigrationPlan (triggers V1→V2 migration if needed).
    static func openWithMigrationPlan(url: URL) throws -> ModelContainer {
        let schema = Schema(versionedSchema: SchemaLatest.self)
        let config = ModelConfiguration(url: url)
        return try ModelContainer(
            for: schema,
            migrationPlan: BabyStepsMigrationPlan.self,
            configurations: [config]
        )
    }
}
