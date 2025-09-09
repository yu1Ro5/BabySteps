import XCTest
import SwiftData
@testable import BabySteps

/// タスク完了機能のマイグレーションテスト
final class TaskMigrationTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUpWithError() throws {
        // インメモリデータベースでテスト
        let schema = Schema([
            Task.self,
            TaskStep.self,
            TaskMigrationPlan.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = modelContainer.mainContext
    }
    
    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
    }
    
    // MARK: - 基本マイグレーションテスト
    
    func testBasicMigration() throws {
        // テストデータ作成（マイグレーション前の状態をシミュレート）
        let task = Task(title: "テストタスク")
        modelContext.insert(task)
        
        // ステップを追加
        for i in 0..<3 {
            let step = TaskStep(order: i)
            step.task = task
            task.addStep(step)
            modelContext.insert(step)
        }
        
        try modelContext.save()
        
        // マイグレーション実行
        let success = TaskMigrationPlan.executeTaskCompletionMigration(modelContext: modelContext)
        XCTAssertTrue(success, "マイグレーションは成功する必要があります")
        
        // マイグレーション後の状態を確認
        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(tasks.count, 1, "タスク数は1である必要があります")
        
        let migratedTask = tasks.first!
        XCTAssertFalse(migratedTask.isCompleted, "デフォルトで未完了状態である必要があります")
        XCTAssertNil(migratedTask.completedAt, "デフォルトでcompletedAtはnilである必要があります")
        XCTAssertEqual(migratedTask.steps.count, 3, "ステップ数は3である必要があります")
    }
    
    func testMultipleTasksMigration() throws {
        // 複数のタスクを作成
        for i in 1...5 {
            let task = Task(title: "テストタスク \(i)")
            modelContext.insert(task)
            
            // 各タスクにステップを追加
            for j in 0..<2 {
                let step = TaskStep(order: j)
                step.task = task
                task.addStep(step)
                modelContext.insert(step)
            }
        }
        
        try modelContext.save()
        
        // マイグレーション実行
        let success = TaskMigrationPlan.executeTaskCompletionMigration(modelContext: modelContext)
        XCTAssertTrue(success, "マイグレーションは成功する必要があります")
        
        // 全タスクの状態を確認
        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(tasks.count, 5, "タスク数は5である必要があります")
        
        for task in tasks {
            XCTAssertFalse(task.isCompleted, "全タスクが未完了状態である必要があります")
            XCTAssertNil(task.completedAt, "全タスクのcompletedAtがnilである必要があります")
            XCTAssertEqual(task.steps.count, 2, "各タスクのステップ数は2である必要があります")
        }
    }
    
    func testPartialCompletionMigration() throws {
        // 一部完了済みのタスクを作成
        let task = Task(title: "部分完了タスク")
        modelContext.insert(task)
        
        // ステップを追加（一部完了）
        for i in 0..<3 {
            let step = TaskStep(order: i)
            step.task = task
            
            if i < 2 {
                step.isCompleted = true
                step.completedAt = Date()
            }
            
            task.addStep(step)
            modelContext.insert(step)
        }
        
        try modelContext.save()
        
        // マイグレーション実行
        let success = TaskMigrationPlan.executeTaskCompletionMigration(modelContext: modelContext)
        XCTAssertTrue(success, "マイグレーションは成功する必要があります")
        
        // 状態確認
        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        
        let migratedTask = tasks.first!
        XCTAssertFalse(migratedTask.isCompleted, "タスク自体は未完了状態である必要があります")
        XCTAssertNil(migratedTask.completedAt, "タスクのcompletedAtはnilである必要があります")
        
        // ステップの状態は保持される
        let completedSteps = migratedTask.steps.filter { $0.isCompleted }
        XCTAssertEqual(completedSteps.count, 2, "完了済みステップ数は2である必要があります")
    }
    
    func testEmptyTaskMigration() throws {
        // 空のタスクを作成
        let task = Task(title: "空のタスク")
        modelContext.insert(task)
        
        try modelContext.save()
        
        // マイグレーション実行
        let success = TaskMigrationPlan.executeTaskCompletionMigration(modelContext: modelContext)
        XCTAssertTrue(success, "マイグレーションは成功する必要があります")
        
        // 状態確認
        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        
        let migratedTask = tasks.first!
        XCTAssertFalse(migratedTask.isCompleted, "空のタスクも未完了状態である必要があります")
        XCTAssertNil(migratedTask.completedAt, "空のタスクのcompletedAtはnilである必要があります")
        XCTAssertEqual(migratedTask.steps.count, 0, "ステップ数は0である必要があります")
    }
    
    func testMigrationOrderPreservation() throws {
        // 複数のタスクを作成（作成順序を保持）
        let task1 = Task(title: "最初のタスク")
        let task2 = Task(title: "2番目のタスク")
        let task3 = Task(title: "3番目のタスク")
        
        modelContext.insert(task1)
        modelContext.insert(task2)
        modelContext.insert(task3)
        
        try modelContext.save()
        
        // マイグレーション実行
        let success = TaskMigrationPlan.executeTaskCompletionMigration(modelContext: modelContext)
        XCTAssertTrue(success, "マイグレーションは成功する必要があります")
        
        // 順序が保持されているか確認
        let descriptor = FetchDescriptor<Task>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let tasks = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(tasks.count, 3, "タスク数は3である必要があります")
        XCTAssertEqual(tasks[0].title, "3番目のタスク", "最初のタスクは3番目である必要があります")
        XCTAssertEqual(tasks[1].title, "2番目のタスク", "2番目のタスクは2番目である必要があります")
        XCTAssertEqual(tasks[2].title, "最初のタスク", "3番目のタスクは最初である必要があります")
    }
    
    func testMigrationStatistics() throws {
        // テストデータ作成
        for i in 1...10 {
            let task = Task(title: "統計テストタスク \(i)")
            modelContext.insert(task)
            
            // ランダムなステップ数
            let stepCount = Int.random(in: 1...5)
            for j in 0..<stepCount {
                let step = TaskStep(order: j)
                step.task = task
                task.addStep(step)
                modelContext.insert(step)
            }
        }
        
        try modelContext.save()
        
        // マイグレーション前の統計
        let beforeDescriptor = FetchDescriptor<Task>()
        let beforeTasks = try modelContext.fetch(beforeDescriptor)
        
        let beforeStepDescriptor = FetchDescriptor<TaskStep>()
        let beforeSteps = try modelContext.fetch(beforeStepDescriptor)
        
        // マイグレーション実行
        let success = TaskMigrationPlan.executeTaskCompletionMigration(modelContext: modelContext)
        XCTAssertTrue(success, "マイグレーションは成功する必要があります")
        
        // マイグレーション後の統計
        let afterDescriptor = FetchDescriptor<Task>()
        let afterTasks = try modelContext.fetch(afterDescriptor)
        
        let afterStepDescriptor = FetchDescriptor<TaskStep>()
        let afterSteps = try modelContext.fetch(afterStepDescriptor)
        
        // データ数は変わらない
        XCTAssertEqual(beforeTasks.count, afterTasks.count, "タスク数は変わらない必要があります")
        XCTAssertEqual(beforeSteps.count, afterSteps.count, "ステップ数は変わらない必要があります")
        
        // 全タスクが未完了状態
        let completedTasks = afterTasks.filter { $0.isCompleted }
        XCTAssertEqual(completedTasks.count, 0, "完了済みタスク数は0である必要があります")
    }
    
    func testNewFeatureFunctionality() throws {
        // マイグレーション実行
        let success = TaskMigrationPlan.executeTaskCompletionMigration(modelContext: modelContext)
        XCTAssertTrue(success, "マイグレーションは成功する必要があります")
        
        // 新しいタスクを作成
        let task = Task(title: "新機能テストタスク")
        modelContext.insert(task)
        
        // ステップを追加
        for i in 0..<3 {
            let step = TaskStep(order: i)
            step.task = task
            task.addStep(step)
            modelContext.insert(step)
        }
        
        try modelContext.save()
        
        // 新機能の動作確認
        XCTAssertFalse(task.isCompleted, "初期状態は未完了である必要があります")
        XCTAssertNil(task.completedAt, "初期状態のcompletedAtはnilである必要があります")
        
        // タスク完了機能をテスト
        task.toggleCompletion()
        XCTAssertTrue(task.isCompleted, "タスク完了後は完了状態である必要があります")
        XCTAssertNotNil(task.completedAt, "タスク完了後はcompletedAtが設定されている必要があります")
        
        // タスク未完了に戻す
        task.toggleCompletion()
        XCTAssertFalse(task.isCompleted, "タスク未完了後は未完了状態である必要があります")
        XCTAssertNil(task.completedAt, "タスク未完了後はcompletedAtがnilである必要があります")
    }
    
    // MARK: - エラーハンドリングテスト
    
    func testMigrationErrorHandling() throws {
        // 無効なデータでマイグレーションをテスト
        let task = Task(title: "")
        modelContext.insert(task)
        
        try modelContext.save()
        
        // マイグレーション実行（エラーが発生しないことを確認）
        let success = TaskMigrationPlan.executeTaskCompletionMigration(modelContext: modelContext)
        XCTAssertTrue(success, "エラーが発生してもマイグレーションは成功する必要があります")
    }
    
    func testMigrationIdempotency() throws {
        // 最初のマイグレーション
        let success1 = TaskMigrationPlan.executeTaskCompletionMigration(modelContext: modelContext)
        XCTAssertTrue(success1, "最初のマイグレーションは成功する必要があります")
        
        // 2回目のマイグレーション（べき等性）
        let success2 = TaskMigrationPlan.executeTaskCompletionMigration(modelContext: modelContext)
        XCTAssertTrue(success2, "2回目のマイグレーションも成功する必要があります")
        
        // マイグレーション記録の確認
        let descriptor = FetchDescriptor<TaskMigrationPlan>()
        let migrations = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(migrations.count, 2, "マイグレーション記録は2件である必要があります")
    }
}