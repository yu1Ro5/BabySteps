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
}
