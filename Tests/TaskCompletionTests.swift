import XCTest
import SwiftData
@testable import BabySteps

/// タスク完了機能のテスト
final class TaskCompletionTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var viewModel: TaskViewModel!
    
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
        viewModel = TaskViewModel(modelContext: modelContext)
    }
    
    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
        viewModel = nil
    }
    
    // MARK: - タスク完了状態切り替えテスト
    
    func testTaskCompletionToggle() throws {
        // テストタスクを作成
        let task = viewModel.createTaskWithSteps(title: "完了テストタスク", stepCount: 3)
        
        // 初期状態確認
        XCTAssertFalse(task.isCompleted, "初期状態は未完了である必要があります")
        XCTAssertNil(task.completedAt, "初期状態のcompletedAtはnilである必要があります")
        
        // タスクを完了に
        viewModel.toggleTaskCompletion(task)
        
        XCTAssertTrue(task.isCompleted, "タスク完了後は完了状態である必要があります")
        XCTAssertNotNil(task.completedAt, "タスク完了後はcompletedAtが設定されている必要があります")
        
        // 完了日時の確認
        if let completedAt = task.completedAt {
            XCTAssertLessThanOrEqual(completedAt.timeIntervalSinceNow, 1.0, "完了日時は現在時刻である必要があります")
        }
    }
    
    func testTaskUncompletionToggle() throws {
        // 完了済みタスクを作成
        let task = viewModel.createTaskWithSteps(title: "未完了テストタスク", stepCount: 2)
        task.isCompleted = true
        task.completedAt = Date()
        
        try modelContext.save()
        
        // タスクを未完了に
        viewModel.toggleTaskCompletion(task)
        
        XCTAssertFalse(task.isCompleted, "タスク未完了後は未完了状態である必要があります")
        XCTAssertNil(task.completedAt, "タスク未完了後はcompletedAtがnilである必要があります")
    }
    
    func testTaskCompletionWithSteps() throws {
        // ステップ付きタスクを作成
        let task = viewModel.createTaskWithSteps(title: "ステップ付きタスク", stepCount: 5)
        
        // 一部のステップを完了
        for i in 0..<3 {
            let step = task.steps[i]
            step.isCompleted = true
            step.completedAt = Date()
        }
        
        try modelContext.save()
        
        // タスク全体を完了
        viewModel.toggleTaskCompletion(task)
        
        XCTAssertTrue(task.isCompleted, "タスク全体は完了状態である必要があります")
        XCTAssertNotNil(task.completedAt, "タスク全体のcompletedAtが設定されている必要があります")
        
        // ステップの状態は保持される
        let completedSteps = task.steps.filter { $0.isCompleted }
        XCTAssertEqual(completedSteps.count, 3, "完了済みステップ数は3である必要があります")
        
        let incompleteSteps = task.steps.filter { !$0.isCompleted }
        XCTAssertEqual(incompleteSteps.count, 2, "未完了ステップ数は2である必要があります")
    }
    
    func testTaskCompletionIndependence() throws {
        // タスクとステップを作成
        let task = viewModel.createTaskWithSteps(title: "独立性テストタスク", stepCount: 4)
        
        // タスク全体を完了
        viewModel.toggleTaskCompletion(task)
        XCTAssertTrue(task.isCompleted, "タスク全体は完了状態である必要があります")
        
        // ステップを個別に操作
        let step = task.steps[0]
        viewModel.toggleStepCompletion(step)
        
        XCTAssertTrue(step.isCompleted, "ステップは完了状態である必要があります")
        XCTAssertTrue(task.isCompleted, "タスク全体の完了状態は保持される必要があります")
        
        // ステップを未完了に
        viewModel.toggleStepCompletion(step)
        
        XCTAssertFalse(step.isCompleted, "ステップは未完了状態である必要があります")
        XCTAssertTrue(task.isCompleted, "タスク全体の完了状態は保持される必要があります")
    }
    
    // MARK: - データ永続化テスト
    
    func testTaskCompletionPersistence() throws {
        // タスクを作成
        let task = viewModel.createTaskWithSteps(title: "永続化テストタスク", stepCount: 2)
        
        // タスクを完了
        viewModel.toggleTaskCompletion(task)
        
        let completedAt = task.completedAt
        XCTAssertNotNil(completedAt, "完了日時が設定されている必要があります")
        
        // 新しいコンテキストでデータを再取得
        let newContext = modelContainer.mainContext
        let descriptor = FetchDescriptor<Task>()
        let tasks = try newContext.fetch(descriptor)
        
        XCTAssertEqual(tasks.count, 1, "タスク数は1である必要があります")
        
        let retrievedTask = tasks.first!
        XCTAssertTrue(retrievedTask.isCompleted, "取得したタスクは完了状態である必要があります")
        XCTAssertNotNil(retrievedTask.completedAt, "取得したタスクのcompletedAtが設定されている必要があります")
        
        // 完了日時の比較
        if let originalCompletedAt = completedAt, let retrievedCompletedAt = retrievedTask.completedAt {
            XCTAssertEqual(originalCompletedAt.timeIntervalSince1970, retrievedCompletedAt.timeIntervalSince1970, accuracy: 1.0, "完了日時が正しく保存されている必要があります")
        }
    }
    
    func testMultipleTaskCompletionPersistence() throws {
        // 複数のタスクを作成
        var tasks: [Task] = []
        for i in 1...5 {
            let task = viewModel.createTaskWithSteps(title: "永続化テストタスク \(i)", stepCount: 3)
            tasks.append(task)
        }
        
        // 一部のタスクを完了
        for i in 0..<3 {
            viewModel.toggleTaskCompletion(tasks[i])
        }
        
        // データを再取得
        let newContext = modelContainer.mainContext
        let descriptor = FetchDescriptor<Task>()
        let retrievedTasks = try newContext.fetch(descriptor)
        
        XCTAssertEqual(retrievedTasks.count, 5, "タスク数は5である必要があります")
        
        let completedTasks = retrievedTasks.filter { $0.isCompleted }
        XCTAssertEqual(completedTasks.count, 3, "完了済みタスク数は3である必要があります")
        
        let incompleteTasks = retrievedTasks.filter { !$0.isCompleted }
        XCTAssertEqual(incompleteTasks.count, 2, "未完了タスク数は2である必要があります")
    }
    
    // MARK: - エッジケーステスト
    
    func testEmptyTaskCompletion() throws {
        // 空のタスクを作成
        let task = Task(title: "空のタスク")
        modelContext.insert(task)
        try modelContext.save()
        
        // タスクを完了
        viewModel.toggleTaskCompletion(task)
        
        XCTAssertTrue(task.isCompleted, "空のタスクも完了できる必要があります")
        XCTAssertNotNil(task.completedAt, "空のタスクのcompletedAtが設定されている必要があります")
    }
    
    func testTaskCompletionWithAllStepsCompleted() throws {
        // 全ステップ完了済みタスクを作成
        let task = viewModel.createTaskWithSteps(title: "全ステップ完了タスク", stepCount: 3)
        
        // 全ステップを完了
        for step in task.steps {
            step.isCompleted = true
            step.completedAt = Date()
        }
        
        try modelContext.save()
        
        // タスク全体を完了
        viewModel.toggleTaskCompletion(task)
        
        XCTAssertTrue(task.isCompleted, "タスク全体は完了状態である必要があります")
        XCTAssertNotNil(task.completedAt, "タスク全体のcompletedAtが設定されている必要があります")
        
        // 全ステップも完了状態
        let allStepsCompleted = task.steps.allSatisfy { $0.isCompleted }
        XCTAssertTrue(allStepsCompleted, "全ステップが完了状態である必要があります")
    }
    
    func testTaskCompletionRapidToggle() throws {
        // タスクを作成
        let task = viewModel.createTaskWithSteps(title: "高速切り替えテストタスク", stepCount: 2)
        
        // 高速で切り替え
        for _ in 0..<10 {
            viewModel.toggleTaskCompletion(task)
        }
        
        // 最終状態確認
        XCTAssertTrue(task.isCompleted, "最終状態は完了である必要があります")
        XCTAssertNotNil(task.completedAt, "最終状態のcompletedAtが設定されている必要があります")
        
        // もう一度切り替え
        viewModel.toggleTaskCompletion(task)
        
        XCTAssertFalse(task.isCompleted, "切り替え後は未完了である必要があります")
        XCTAssertNil(task.completedAt, "切り替え後のcompletedAtはnilである必要があります")
    }
    
    // MARK: - パフォーマンステスト
    
    func testTaskCompletionPerformance() throws {
        // 大量のタスクを作成
        let taskCount = 100
        var tasks: [Task] = []
        
        for i in 1...taskCount {
            let task = viewModel.createTaskWithSteps(title: "パフォーマンステストタスク \(i)", stepCount: 5)
            tasks.append(task)
        }
        
        // パフォーマンス測定
        measure {
            for task in tasks {
                viewModel.toggleTaskCompletion(task)
            }
        }
        
        // 結果確認
        let descriptor = FetchDescriptor<Task>()
        let retrievedTasks = try modelContext.fetch(descriptor)
        
        let completedTasks = retrievedTasks.filter { $0.isCompleted }
        XCTAssertEqual(completedTasks.count, taskCount, "全タスクが完了状態である必要があります")
    }
    
    // MARK: - データ整合性テスト
    
    func testTaskCompletionDataIntegrity() throws {
        // タスクを作成
        let task = viewModel.createTaskWithSteps(title: "整合性テストタスク", stepCount: 3)
        
        // タスクを完了
        viewModel.toggleTaskCompletion(task)
        
        // データ整合性チェック
        let isValid = DataIntegrityChecker.performQuickCheck(modelContext: modelContext)
        XCTAssertTrue(isValid, "データ整合性に問題がない必要があります")
        
        // 包括的チェック
        let report = DataIntegrityChecker.performComprehensiveCheck(modelContext: modelContext)
        XCTAssertTrue(report.isValid, "包括的チェックでも問題がない必要があります")
        XCTAssertEqual(report.issues.count, 0, "問題が0件である必要があります")
    }
    
    func testTaskCompletionWithCorruptedData() throws {
        // 意図的に不整合なデータを作成
        let task = Task(title: "不整合データタスク")
        task.isCompleted = true
        task.completedAt = nil  // 不整合
        modelContext.insert(task)
        
        try modelContext.save()
        
        // データ修復
        let report = DataIntegrityChecker.performComprehensiveCheck(modelContext: modelContext)
        
        // 修復が実行されることを確認
        XCTAssertTrue(report.repairedCount > 0, "データ修復が実行される必要があります")
        
        // 修復後の状態確認
        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        
        let repairedTask = tasks.first!
        XCTAssertTrue(repairedTask.isCompleted, "修復後は完了状態である必要があります")
        XCTAssertNotNil(repairedTask.completedAt, "修復後のcompletedAtが設定されている必要があります")
    }
}