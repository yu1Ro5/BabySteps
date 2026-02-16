import XCTest
import SwiftData
@testable import BabySteps

final class TaskViewModelTests: XCTestCase {

    var container: ModelContainer!
    var modelContext: ModelContext!
    var viewModel: TaskViewModel!

    override func setUpWithError() throws {
        container = try TestHelpers.makeInMemoryContainer()
        modelContext = ModelContext(container)
        viewModel = TaskViewModel(modelContext: modelContext)
    }

    override func tearDownWithError() throws {
        container = nil
        modelContext = nil
        viewModel = nil
    }

    func testCreateTaskWithSteps() throws {
        let task = viewModel.createTaskWithSteps(title: "My Task", stepCount: 3)
        XCTAssertEqual(task.title, "My Task")
        XCTAssertEqual(task.steps.count, 3)
        XCTAssertEqual(task.order, 0)
    }

    func testDeleteTask() throws {
        let task = viewModel.createTaskWithSteps(title: "To Delete", stepCount: 1)
        viewModel.deleteTask(task)
        let tasks = try viewModel.fetchTasks()
        XCTAssertTrue(tasks.isEmpty)
    }

    func testToggleStepCompletion() throws {
        let task = viewModel.createTaskWithSteps(title: "Toggle", stepCount: 1)
        let step = task.steps[0]
        XCTAssertFalse(step.isCompleted)
        viewModel.toggleStepCompletion(step)
        XCTAssertTrue(step.isCompleted)
        viewModel.toggleStepCompletion(step)
        XCTAssertFalse(step.isCompleted)
    }

    func testMoveTasks() throws {
        let t1 = viewModel.createTaskWithSteps(title: "A", stepCount: 1)
        let t2 = viewModel.createTaskWithSteps(title: "B", stepCount: 1)
        let t3 = viewModel.createTaskWithSteps(title: "C", stepCount: 1)
        let tasks = [t1, t2, t3]
        viewModel.moveTasks(tasks, from: IndexSet(integer: 0), to: 3)
        let sorted = tasks.sorted { $0.order < $1.order }
        XCTAssertEqual(sorted.map(\.title), ["B", "C", "A"])
    }

}
