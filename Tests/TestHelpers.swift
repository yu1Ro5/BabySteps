import Foundation
import SwiftData
@testable import BabySteps

enum TestHelpers {
    static func makeInMemoryContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: Task.self, TaskStep.self,
            configurations: config
        )
    }
}
