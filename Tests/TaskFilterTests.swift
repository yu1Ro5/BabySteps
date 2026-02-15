import XCTest
import SwiftData
@testable import BabySteps

final class TaskFilterTests: XCTestCase {

    var container: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        container = try TestHelpers.makeInMemoryContainer()
        modelContext = ModelContext(container)
    }

    override func tearDownWithError() throws {
        container = nil
        modelContext = nil
    }

    func testCompletedFilter_taskWithAllStepsCompleted() throws {
        let task = Task(title: "Completed")
        modelContext.insert(task)
        let step = TaskStep(order: 0)
        step.isCompleted = true
        task.addStep(step)
        modelContext.insert(step)
        try modelContext.save()
        XCTAssertTrue(task.isCompleted)
    }

    func testInProgressFilter_taskWithIncompleteSteps() throws {
        let task = Task(title: "In Progress")
        modelContext.insert(task)
        let step = TaskStep(order: 0)
        task.addStep(step)
        modelContext.insert(step)
        try modelContext.save()
        XCTAssertFalse(task.isCompleted)
        XCTAssertFalse(task.steps.isEmpty)
    }

    func testAllFilter_taskWithCompletedSteps() throws {
        let task = Task(title: "Done")
        modelContext.insert(task)
        let step = TaskStep(order: 0)
        step.isCompleted = true
        task.addStep(step)
        modelContext.insert(step)
        try modelContext.save()
        XCTAssertTrue(task.isCompleted)
    }
}
