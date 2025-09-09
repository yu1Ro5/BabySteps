import XCTest
import SwiftData
@testable import BabySteps

/// エンドツーエンドテスト
final class EndToEndTests: XCTestCase {
    
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
    
    // MARK: - 完全なワークフローテスト
    
    func testCompleteWorkflow() throws {
        print("🧪 完全なワークフローテスト開始")
        
        // 1. マイグレーション前のデータ作成
        print("📝 ステップ1: マイグレーション前のデータ作成")
        let preMigrationTasks = createPreMigrationData()
        XCTAssertEqual(preMigrationTasks.count, 5, "マイグレーション前のタスク数は5である必要があります")
        
        // 2. マイグレーション実行
        print("🔄 ステップ2: マイグレーション実行")
        let migrationSuccess = TaskMigrationPlan.executeTaskCompletionMigration(modelContext: modelContext)
        XCTAssertTrue(migrationSuccess, "マイグレーションは成功する必要があります")
        
        // 3. マイグレーション後のデータ確認
        print("✅ ステップ3: マイグレーション後のデータ確認")
        let postMigrationTasks = try viewModel.fetchTasks()
        XCTAssertEqual(postMigrationTasks.count, 5, "マイグレーション後のタスク数は5である必要があります")
        
        // 全タスクが未完了状態であることを確認
        for task in postMigrationTasks {
            XCTAssertFalse(task.isCompleted, "マイグレーション後は全タスクが未完了状態である必要があります")
            XCTAssertNil(task.completedAt, "マイグレーション後は全タスクのcompletedAtがnilである必要があります")
        }
        
        // 4. 新機能の動作確認
        print("🎯 ステップ4: 新機能の動作確認")
        testNewFeatureFunctionality(tasks: postMigrationTasks)
        
        // 5. データ永続化確認
        print("💾 ステップ5: データ永続化確認")
        testDataPersistence()
        
        // 6. データ整合性確認
        print("🔍 ステップ6: データ整合性確認")
        testDataIntegrity()
        
        print("🎉 完全なワークフローテスト完了")
    }
    
    // MARK: - マイグレーション前のデータ作成
    
    private func createPreMigrationData() -> [Task] {
        var tasks: [Task] = []
        
        // 基本的なタスク
        let task1 = Task(title: "基本タスク")
        modelContext.insert(task1)
        
        // ステップ付きタスク
        let task2 = Task(title: "ステップ付きタスク")
        modelContext.insert(task2)
        for i in 0..<3 {
            let step = TaskStep(order: i)
            step.task = task2
            task2.addStep(step)
            modelContext.insert(step)
        }
        
        // 一部完了済みステップのタスク
        let task3 = Task(title: "部分完了タスク")
        modelContext.insert(task3)
        for i in 0..<5 {
            let step = TaskStep(order: i)
            step.task = task3
            
            if i < 2 {
                step.isCompleted = true
                step.completedAt = Date()
            }
            
            task3.addStep(step)
            modelContext.insert(step)
        }
        
        // 全ステップ完了済みタスク
        let task4 = Task(title: "全ステップ完了タスク")
        modelContext.insert(task4)
        for i in 0..<3 {
            let step = TaskStep(order: i)
            step.task = task4
            step.isCompleted = true
            step.completedAt = Date()
            task4.addStep(step)
            modelContext.insert(step)
        }
        
        // 空のタスク
        let task5 = Task(title: "空のタスク")
        modelContext.insert(task5)
        
        tasks = [task1, task2, task3, task4, task5]
        
        do {
            try modelContext.save()
        } catch {
            XCTFail("データ保存に失敗しました: \(error)")
        }
        
        return tasks
    }
    
    // MARK: - 新機能の動作確認
    
    private func testNewFeatureFunctionality(tasks: [Task]) throws {
        // タスク完了機能のテスト
        let task = tasks[0]
        
        // タスクを完了
        viewModel.toggleTaskCompletion(task)
        XCTAssertTrue(task.isCompleted, "タスク完了機能が動作する必要があります")
        XCTAssertNotNil(task.completedAt, "タスク完了時にcompletedAtが設定される必要があります")
        
        // タスクを未完了に戻す
        viewModel.toggleTaskCompletion(task)
        XCTAssertFalse(task.isCompleted, "タスク未完了機能が動作する必要があります")
        XCTAssertNil(task.completedAt, "タスク未完了時にcompletedAtがクリアされる必要があります")
        
        // ステップ付きタスクのテスト
        let stepTask = tasks[1]
        XCTAssertEqual(stepTask.steps.count, 3, "ステップ付きタスクのステップ数は3である必要があります")
        
        // タスク全体を完了（ステップの状態は保持）
        viewModel.toggleTaskCompletion(stepTask)
        XCTAssertTrue(stepTask.isCompleted, "ステップ付きタスクの完了機能が動作する必要があります")
        
        // ステップの状態は保持される
        let completedSteps = stepTask.steps.filter { $0.isCompleted }
        XCTAssertEqual(completedSteps.count, 0, "ステップの完了状態は保持される必要があります")
        
        // ステップを個別に操作
        let step = stepTask.steps[0]
        viewModel.toggleStepCompletion(step)
        XCTAssertTrue(step.isCompleted, "ステップの完了機能が動作する必要があります")
        XCTAssertTrue(stepTask.isCompleted, "タスク全体の完了状態は保持される必要があります")
    }
    
    // MARK: - データ永続化確認
    
    private func testDataPersistence() throws {
        // 新しいタスクを作成
        let task = viewModel.createTaskWithSteps(title: "永続化テストタスク", stepCount: 3)
        
        // タスクを完了
        viewModel.toggleTaskCompletion(task)
        let completedAt = task.completedAt
        XCTAssertNotNil(completedAt, "完了日時が設定されている必要があります")
        
        // 一部のステップを完了
        for i in 0..<2 {
            let step = task.steps[i]
            viewModel.toggleStepCompletion(step)
        }
        
        // 新しいコンテキストでデータを再取得
        let newContext = modelContainer.mainContext
        let descriptor = FetchDescriptor<Task>()
        let tasks = try newContext.fetch(descriptor)
        
        XCTAssertEqual(tasks.count, 6, "総タスク数は6である必要があります")
        
        // 永続化テストタスクを検索
        let persistedTask = tasks.first { $0.title == "永続化テストタスク" }
        XCTAssertNotNil(persistedTask, "永続化テストタスクが見つかる必要があります")
        
        if let task = persistedTask {
            XCTAssertTrue(task.isCompleted, "永続化されたタスクは完了状態である必要があります")
            XCTAssertNotNil(task.completedAt, "永続化されたタスクのcompletedAtが設定されている必要があります")
            
            // 完了日時の比較
            if let originalCompletedAt = completedAt, let persistedCompletedAt = task.completedAt {
                XCTAssertEqual(originalCompletedAt.timeIntervalSince1970, persistedCompletedAt.timeIntervalSince1970, accuracy: 1.0, "完了日時が正しく永続化されている必要があります")
            }
            
            // ステップの状態確認
            let completedSteps = task.steps.filter { $0.isCompleted }
            XCTAssertEqual(completedSteps.count, 2, "完了済みステップ数は2である必要があります")
        }
    }
    
    // MARK: - データ整合性確認
    
    private func testDataIntegrity() throws {
        // 簡易チェック
        let quickCheckResult = DataIntegrityChecker.performQuickCheck(modelContext: modelContext)
        XCTAssertTrue(quickCheckResult, "簡易データ整合性チェックに問題がない必要があります")
        
        // 包括的チェック
        let report = DataIntegrityChecker.performComprehensiveCheck(modelContext: modelContext)
        XCTAssertTrue(report.isValid, "包括的データ整合性チェックに問題がない必要があります")
        XCTAssertEqual(report.issues.count, 0, "データ整合性の問題が0件である必要があります")
        XCTAssertEqual(report.repairedCount, 0, "データ修復件数が0件である必要があります")
        
        print("📊 データ整合性チェック結果:")
        print("   - 総タスク数: \(report.totalTasks)")
        print("   - 総ステップ数: \(report.totalSteps)")
        print("   - 整合性: \(report.isValid ? "✅ 正常" : "❌ 問題あり")")
        print("   - 修復件数: \(report.repairedCount)")
    }
    
    // MARK: - 複雑なシナリオテスト
    
    func testComplexScenario() throws {
        print("🧪 複雑なシナリオテスト開始")
        
        // 1. 大量のデータを作成
        print("📝 ステップ1: 大量データ作成")
        let largeDataset = MigrationTestDataCreator.createTestData(
            type: .largeDataset,
            modelContext: modelContext,
            count: 50
        )
        XCTAssertEqual(largeDataset.count, 50, "大量データの作成が成功する必要があります")
        
        // 2. マイグレーション実行
        print("🔄 ステップ2: 大量データのマイグレーション")
        let migrationSuccess = TaskMigrationPlan.executeTaskCompletionMigration(modelContext: modelContext)
        XCTAssertTrue(migrationSuccess, "大量データのマイグレーションは成功する必要があります")
        
        // 3. 複雑な操作を実行
        print("🎯 ステップ3: 複雑な操作実行")
        let tasks = try viewModel.fetchTasks()
        
        // ランダムにタスクを完了/未完了
        for i in 0..<20 {
            let task = tasks[i]
            if i % 2 == 0 {
                viewModel.toggleTaskCompletion(task)
            }
        }
        
        // ランダムにステップを完了/未完了
        for task in tasks.prefix(10) {
            for step in task.steps.prefix(3) {
                if Bool.random() {
                    viewModel.toggleStepCompletion(step)
                }
            }
        }
        
        // 4. データ整合性確認
        print("🔍 ステップ4: 複雑な操作後のデータ整合性確認")
        let report = DataIntegrityChecker.performComprehensiveCheck(modelContext: modelContext)
        XCTAssertTrue(report.isValid, "複雑な操作後もデータ整合性に問題がない必要があります")
        
        // 5. 統計情報の確認
        print("📊 ステップ5: 統計情報確認")
        MigrationTestDataCreator.printTestDataStatistics(modelContext: modelContext)
        
        print("🎉 複雑なシナリオテスト完了")
    }
    
    // MARK: - エラーケーステスト
    
    func testErrorHandling() throws {
        print("🧪 エラーケーステスト開始")
        
        // 1. 不整合なデータを作成
        print("📝 ステップ1: 不整合データ作成")
        let corruptedData = MigrationTestDataCreator.createTestData(
            type: .corrupted,
            modelContext: modelContext,
            count: 10
        )
        XCTAssertEqual(corruptedData.count, 10, "不整合データの作成が成功する必要があります")
        
        // 2. データ整合性チェック（問題検出）
        print("🔍 ステップ2: 問題検出")
        let initialReport = DataIntegrityChecker.performComprehensiveCheck(modelContext: modelContext)
        XCTAssertFalse(initialReport.isValid, "不整合データの問題が検出される必要があります")
        XCTAssertGreaterThan(initialReport.issues.count, 0, "問題が検出される必要があります")
        
        // 3. データ修復
        print("🔧 ステップ3: データ修復")
        let repairReport = DataIntegrityChecker.performComprehensiveCheck(modelContext: modelContext)
        XCTAssertGreaterThan(repairReport.repairedCount, 0, "データ修復が実行される必要があります")
        
        // 4. 修復後の確認
        print("✅ ステップ4: 修復後確認")
        let finalReport = DataIntegrityChecker.performComprehensiveCheck(modelContext: modelContext)
        XCTAssertTrue(finalReport.isValid, "修復後はデータ整合性に問題がない必要があります")
        XCTAssertEqual(finalReport.issues.count, 0, "修復後は問題が0件である必要があります")
        
        print("🎉 エラーケーステスト完了")
    }
    
    // MARK: - パフォーマンステスト
    
    func testPerformance() throws {
        print("🧪 パフォーマンステスト開始")
        
        // 1. 大量データ作成のパフォーマンス
        print("📝 ステップ1: 大量データ作成パフォーマンス")
        measure {
            MigrationTestDataCreator.clearTestData(modelContext: modelContext)
            _ = MigrationTestDataCreator.createTestData(
                type: .largeDataset,
                modelContext: modelContext,
                count: 100
            )
        }
        
        // 2. マイグレーションのパフォーマンス
        print("🔄 ステップ2: マイグレーションパフォーマンス")
        measure {
            _ = TaskMigrationPlan.executeTaskCompletionMigration(modelContext: modelContext)
        }
        
        // 3. データ整合性チェックのパフォーマンス
        print("🔍 ステップ3: データ整合性チェックパフォーマンス")
        measure {
            _ = DataIntegrityChecker.performComprehensiveCheck(modelContext: modelContext)
        }
        
        // 4. タスク操作のパフォーマンス
        print("🎯 ステップ4: タスク操作パフォーマンス")
        let tasks = try viewModel.fetchTasks()
        
        measure {
            for task in tasks.prefix(50) {
                viewModel.toggleTaskCompletion(task)
            }
        }
        
        print("🎉 パフォーマンステスト完了")
    }
    
    // MARK: - クリーンアップテスト
    
    func testCleanup() throws {
        print("🧪 クリーンアップテスト開始")
        
        // テストデータを作成
        _ = MigrationTestDataCreator.createTestData(
            type: .mixed,
            modelContext: modelContext,
            count: 20
        )
        
        // データ確認
        let beforeDescriptor = FetchDescriptor<Task>()
        let beforeTasks = try modelContext.fetch(beforeDescriptor)
        XCTAssertGreaterThan(beforeTasks.count, 0, "テストデータが作成されている必要があります")
        
        // クリーンアップ実行
        MigrationTestDataCreator.clearTestData(modelContext: modelContext)
        
        // クリーンアップ後の確認
        let afterDescriptor = FetchDescriptor<Task>()
        let afterTasks = try modelContext.fetch(afterDescriptor)
        XCTAssertEqual(afterTasks.count, 0, "クリーンアップ後はタスク数が0である必要があります")
        
        print("🎉 クリーンアップテスト完了")
    }
}