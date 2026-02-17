import Foundation
import SwiftData
import XCTest
@testable import BabySteps

/// Tests for BabyStepsMigrationPlan (V1 → V2: Task.order Int? → Int).
final class MigrationPlanTests: XCTestCase {

    func testMigrationFromV1ToV2() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let storeURL = tempDir.appendingPathComponent("default.store")

        // 1. Create V1 store and insert tasks (V1 has no order)
        do {
            let v1Container = try TestHelpers.makeV1Store(at: storeURL)
            let ctx = ModelContext(v1Container)
            let t1 = SchemaV1.Task(title: "A")
            let t2 = SchemaV1.Task(title: "B")
            ctx.insert(t1)
            ctx.insert(t2)
            try ctx.save()
        }
        // V1 container released; store file closed

        // 2. Open same store with MigrationPlan (triggers migration)
        let migratedContainer = try TestHelpers.openWithMigrationPlan(url: storeURL)
        let migratedCtx = ModelContext(migratedContainer)
        let descriptor = FetchDescriptor<Task>(sortBy: [SortDescriptor(\.order, order: .forward)])
        let tasks = try migratedCtx.fetch(descriptor)

        XCTAssertEqual(tasks.count, 2)
        XCTAssertEqual(tasks[0].order, 0)
        XCTAssertEqual(tasks[1].order, 1)
        XCTAssertEqual(tasks.map { $0.title }.sorted(), ["A", "B"])
    }
}
