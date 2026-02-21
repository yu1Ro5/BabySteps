import XCTest
import SwiftData
@testable import BabySteps

/// WidgetDataProvider の振る舞いを検証するテスト。
/// t_wada 推奨: Arrange-Act-Assert、振る舞いの検証、明確なテスト名。
final class WidgetDataProviderTests: XCTestCase {

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

    // MARK: - データが空のとき

    func test空のとき今日の完了数と総数は0になる() throws {
        // Arrange: タスク・ステップなし
        // Act
        let entry = WidgetDataProvider.fetchProgress(context: modelContext, referenceDate: Date())

        // Assert
        XCTAssertEqual(entry.todayCompletedCount, 0)
        XCTAssertEqual(entry.todayTotalCount, 0)
        XCTAssertEqual(entry.completedTasksCount, 0)
        XCTAssertEqual(entry.totalTasksCount, 0)
    }

    // MARK: - 今日完了したステップ

    func test今日完了したステップのみがtodayCompletedCountに含まれる() throws {
        // Arrange: タスク1件、ステップ2件、両方完了
        let task = SchemaV2.Task(title: "Task")
        task.order = 0
        modelContext.insert(task)
        for i in 0..<2 {
            let step = SchemaV2.TaskStep(order: i)
            step.task = task
            task.addStep(step)
            modelContext.insert(step)
        }
        task.steps.forEach { $0.toggleCompletion() }
        try modelContext.save()

        // Act
        let entry = WidgetDataProvider.fetchProgress(context: modelContext, referenceDate: Date())

        // Assert
        XCTAssertEqual(entry.todayCompletedCount, 2)
        XCTAssertEqual(entry.todayTotalCount, 2)
        XCTAssertEqual(entry.completedTasksCount, 1)
        XCTAssertEqual(entry.totalTasksCount, 1)
    }

    // MARK: - 昨日完了したステップ

    func test昨日完了したステップはtodayCompletedCountに含まれない() throws {
        // Arrange: タスク1件、ステップ1件を完了し、completedAt を昨日に設定
        let task = SchemaV2.Task(title: "Task")
        task.order = 0
        modelContext.insert(task)
        let step = SchemaV2.TaskStep(order: 0)
        step.task = task
        task.addStep(step)
        modelContext.insert(step)
        step.toggleCompletion()
        let calendar = Calendar.current
        step.completedAt = calendar.date(byAdding: .day, value: -1, to: Date())
        try modelContext.save()

        // Act
        let entry = WidgetDataProvider.fetchProgress(context: modelContext, referenceDate: Date())

        // Assert
        XCTAssertEqual(entry.todayCompletedCount, 0)
        XCTAssertEqual(entry.todayTotalCount, 1)
    }

    // MARK: - 複数タスク・ステップ

    func test複数タスクがあるときtotalStepsとcompletedTasksCountが正しく集計される() throws {
        // Arrange: タスク3件（完了1、進行中2）、ステップ計6件
        let viewModel = TaskViewModel(modelContext: modelContext)
        let t1 = viewModel.createTaskWithSteps(title: "A", stepCount: 2)
        let t2 = viewModel.createTaskWithSteps(title: "B", stepCount: 2)
        let t3 = viewModel.createTaskWithSteps(title: "C", stepCount: 2)
        t1.steps.forEach { viewModel.toggleStepCompletion($0) }

        // Act
        let entry = WidgetDataProvider.fetchProgress(context: modelContext, referenceDate: Date())

        // Assert
        XCTAssertEqual(entry.todayCompletedCount, 2)
        XCTAssertEqual(entry.todayTotalCount, 6)
        XCTAssertEqual(entry.completedTasksCount, 1)
        XCTAssertEqual(entry.totalTasksCount, 3)
    }

    // MARK: - referenceDate の注入

    func testreferenceDateを指定するとその日付で今日の完了数を集計する() throws {
        // Arrange: ステップ1件を完了（completedAt = 今日）
        let task = SchemaV2.Task(title: "Task")
        task.order = 0
        modelContext.insert(task)
        let step = SchemaV2.TaskStep(order: 0)
        step.task = task
        task.addStep(step)
        modelContext.insert(step)
        step.toggleCompletion()
        try modelContext.save()

        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        step.completedAt = yesterday
        try modelContext.save()

        // Act: referenceDate を昨日にすると、昨日完了したステップがカウントされる
        let entry = WidgetDataProvider.fetchProgress(context: modelContext, referenceDate: yesterday)

        // Assert
        XCTAssertEqual(entry.todayCompletedCount, 1)
        XCTAssertEqual(entry.todayTotalCount, 1)
    }
}
