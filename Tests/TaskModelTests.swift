import XCTest
import SwiftData
@testable import BabySteps

final class TaskModelTests: XCTestCase {

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

    func testIsCompleted_emptySteps_returnsFalse() throws {
        let task = Task(title: "Test")
        modelContext.insert(task)
        try modelContext.save()
        XCTAssertFalse(task.isCompleted)
    }

    func testIsCompleted_allStepsCompleted_returnsTrue() throws {
        let task = Task(title: "Test")
        modelContext.insert(task)
        for i in 0..<2 {
            let step = TaskStep(order: i)
            step.isCompleted = true
            task.addStep(step)
            modelContext.insert(step)
        }
        try modelContext.save()
        XCTAssertTrue(task.isCompleted)
    }

    func testIsCompleted_someStepsIncomplete_returnsFalse() throws {
        let task = Task(title: "Test")
        modelContext.insert(task)
        let step1 = TaskStep(order: 0)
        let step2 = TaskStep(order: 1)
        step1.isCompleted = true
        task.addStep(step1)
        task.addStep(step2)
        modelContext.insert(step1)
        modelContext.insert(step2)
        try modelContext.save()
        XCTAssertFalse(task.isCompleted)
    }

    func testCompletedStepsCount() throws {
        let task = Task(title: "Test")
        modelContext.insert(task)
        let step1 = TaskStep(order: 0)
        let step2 = TaskStep(order: 1)
        step1.isCompleted = true
        task.addStep(step1)
        task.addStep(step2)
        modelContext.insert(step1)
        modelContext.insert(step2)
        try modelContext.save()
        XCTAssertEqual(task.completedStepsCount, 1)
        XCTAssertEqual(task.totalStepsCount, 2)
    }
}
