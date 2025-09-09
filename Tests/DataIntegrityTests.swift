import XCTest
import SwiftData
@testable import BabySteps

/// データ整合性テスト
final class DataIntegrityTests: XCTestCase {
    
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
    
    // MARK: - TaskとTaskStepの関連性テスト
    
    func testTaskStepRelationship() throws {
        // タスクとステップを作成
        let task = Task(title: "関連性テストタスク")
        modelContext.insert(task)
        
        let step1 = TaskStep(order: 0)
        let step2 = TaskStep(order: 1)
        
        step1.task = task
        step2.task = task
        
        task.addStep(step1)
        task.addStep(step2)
        
        modelContext.insert(step1)
        modelContext.insert(step2)
        
        try modelContext.save()
        
        // 関連性の確認
        XCTAssertEqual(task.steps.count, 2, "タスクのステップ数は2である必要があります")
        XCTAssertEqual(step1.task?.id, task.id, "ステップ1のタスクIDが一致する必要があります")
        XCTAssertEqual(step2.task?.id, task.id, "ステップ2のタスクIDが一致する必要があります")
        
        // ステップの順序確認
        let sortedSteps = task.steps.sorted(by: { $0.order < $1.order })
        XCTAssertEqual(sortedSteps[0].order, 0, "最初のステップの順序は0である必要があります")
        XCTAssertEqual(sortedSteps[1].order, 1, "2番目のステップの順序は1である必要があります")
    }
    
    func testStepOrderIntegrity() throws {
        // 複数のステップを持つタスクを作成
        let task = Task(title: "順序整合性テストタスク")
        modelContext.insert(task)
        
        // 順序を意図的にバラバラに追加
        let step3 = TaskStep(order: 2)
        let step1 = TaskStep(order: 0)
        let step2 = TaskStep(order: 1)
        
        step3.task = task
        step1.task = task
        step2.task = task
        
        task.addStep(step3)
        task.addStep(step1)
        task.addStep(step2)
        
        modelContext.insert(step3)
        modelContext.insert(step1)
        modelContext.insert(step2)
        
        try modelContext.save()
        
        // 順序の整合性確認
        let sortedSteps = task.steps.sorted(by: { $0.order < $1.order })
        XCTAssertEqual(sortedSteps.count, 3, "ステップ数は3である必要があります")
        
        for (index, step) in sortedSteps.enumerated() {
            XCTAssertEqual(step.order, index, "ステップ\(index)の順序は\(index)である必要があります")
        }
    }
    
    func testTaskStepBidirectionalRelationship() throws {
        // タスクとステップを作成
        let task = Task(title: "双方向関連性テストタスク")
        modelContext.insert(task)
        
        let step = TaskStep(order: 0)
        step.task = task
        task.addStep(step)
        
        modelContext.insert(step)
        try modelContext.save()
        
        // 双方向関連性の確認
        XCTAssertEqual(task.steps.count, 1, "タスクのステップ数は1である必要があります")
        XCTAssertEqual(task.steps.first?.id, step.id, "タスクのステップIDが一致する必要があります")
        XCTAssertEqual(step.task?.id, task.id, "ステップのタスクIDが一致する必要があります")
        
        // ステップを削除
        task.removeStep(step)
        modelContext.delete(step)
        try modelContext.save()
        
        // 削除後の確認
        XCTAssertEqual(task.steps.count, 0, "ステップ削除後は0である必要があります")
    }
    
    // MARK: - 完了状態の論理的一貫性テスト
    
    func testTaskCompletionLogicConsistency() throws {
        // タスクを作成
        let task = Task(title: "論理一貫性テストタスク")
        modelContext.insert(task)
        
        // ステップを追加
        for i in 0..<3 {
            let step = TaskStep(order: i)
            step.task = task
            task.addStep(step)
            modelContext.insert(step)
        }
        
        try modelContext.save()
        
        // タスクを完了
        task.isCompleted = true
        task.completedAt = Date()
        
        // 完了状態の論理性確認
        XCTAssertTrue(task.isCompleted, "タスクは完了状態である必要があります")
        XCTAssertNotNil(task.completedAt, "タスクのcompletedAtが設定されている必要があります")
        
        if let completedAt = task.completedAt {
            XCTAssertLessThanOrEqual(completedAt.timeIntervalSinceNow, 1.0, "完了日時は現在時刻である必要があります")
            XCTAssertGreaterThanOrEqual(completedAt, task.createdAt, "完了日時は作成日時以降である必要があります")
        }
        
        // タスクを未完了に
        task.isCompleted = false
        task.completedAt = nil
        
        XCTAssertFalse(task.isCompleted, "タスクは未完了状態である必要があります")
        XCTAssertNil(task.completedAt, "タスクのcompletedAtはnilである必要があります")
    }
    
    func testStepCompletionLogicConsistency() throws {
        // タスクとステップを作成
        let task = Task(title: "ステップ論理一貫性テストタスク")
        modelContext.insert(task)
        
        let step = TaskStep(order: 0)
        step.task = task
        task.addStep(step)
        modelContext.insert(step)
        
        try modelContext.save()
        
        // ステップを完了
        step.isCompleted = true
        step.completedAt = Date()
        
        // 完了状態の論理性確認
        XCTAssertTrue(step.isCompleted, "ステップは完了状態である必要があります")
        XCTAssertNotNil(step.completedAt, "ステップのcompletedAtが設定されている必要があります")
        
        if let completedAt = step.completedAt {
            XCTAssertLessThanOrEqual(completedAt.timeIntervalSinceNow, 1.0, "完了日時は現在時刻である必要があります")
        }
        
        // ステップを未完了に
        step.isCompleted = false
        step.completedAt = nil
        
        XCTAssertFalse(step.isCompleted, "ステップは未完了状態である必要があります")
        XCTAssertNil(step.completedAt, "ステップのcompletedAtはnilである必要があります")
    }
    
    func testTaskStepCompletionIndependence() throws {
        // タスクとステップを作成
        let task = Task(title: "独立性テストタスク")
        modelContext.insert(task)
        
        let step = TaskStep(order: 0)
        step.task = task
        task.addStep(step)
        modelContext.insert(step)
        
        try modelContext.save()
        
        // タスクとステップの完了状態を独立して操作
        task.isCompleted = true
        task.completedAt = Date()
        
        XCTAssertTrue(task.isCompleted, "タスクは完了状態である必要があります")
        XCTAssertFalse(step.isCompleted, "ステップは未完了状態である必要があります")
        
        step.isCompleted = true
        step.completedAt = Date()
        
        XCTAssertTrue(task.isCompleted, "タスクの完了状態は保持される必要があります")
        XCTAssertTrue(step.isCompleted, "ステップは完了状態である必要があります")
        
        task.isCompleted = false
        task.completedAt = nil
        
        XCTAssertFalse(task.isCompleted, "タスクは未完了状態である必要があります")
        XCTAssertTrue(step.isCompleted, "ステップの完了状態は保持される必要があります")
    }
    
    // MARK: - データ修復テスト
    
    func testDataRepairTaskCompletion() throws {
        // 意図的に不整合なタスクを作成
        let task = Task(title: "修復テストタスク")
        task.isCompleted = true
        task.completedAt = nil  // 不整合
        modelContext.insert(task)
        
        try modelContext.save()
        
        // データ修復実行
        let report = DataIntegrityChecker.performComprehensiveCheck(modelContext: modelContext)
        
        XCTAssertTrue(report.repairedCount > 0, "データ修復が実行される必要があります")
        XCTAssertFalse(report.issues.isEmpty, "問題が検出される必要があります")
        
        // 修復後の状態確認
        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        
        let repairedTask = tasks.first!
        XCTAssertTrue(repairedTask.isCompleted, "修復後は完了状態である必要があります")
        XCTAssertNotNil(repairedTask.completedAt, "修復後のcompletedAtが設定されている必要があります")
    }
    
    func testDataRepairStepCompletion() throws {
        // 意図的に不整合なステップを作成
        let task = Task(title: "ステップ修復テストタスク")
        modelContext.insert(task)
        
        let step = TaskStep(order: 0)
        step.task = task
        step.isCompleted = true
        step.completedAt = nil  // 不整合
        task.addStep(step)
        modelContext.insert(step)
        
        try modelContext.save()
        
        // データ修復実行
        let report = DataIntegrityChecker.performComprehensiveCheck(modelContext: modelContext)
        
        XCTAssertTrue(report.repairedCount > 0, "データ修復が実行される必要があります")
        
        // 修復後の状態確認
        let descriptor = FetchDescriptor<TaskStep>()
        let steps = try modelContext.fetch(descriptor)
        
        let repairedStep = steps.first!
        XCTAssertTrue(repairedStep.isCompleted, "修復後は完了状態である必要があります")
        XCTAssertNotNil(repairedStep.completedAt, "修復後のcompletedAtが設定されている必要があります")
    }
    
    func testDataRepairFutureCompletionDate() throws {
        // 未来の完了日時を持つタスクを作成
        let task = Task(title: "未来日時修復テストタスク")
        task.isCompleted = true
        task.completedAt = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        modelContext.insert(task)
        
        try modelContext.save()
        
        // データ修復実行
        let report = DataIntegrityChecker.performComprehensiveCheck(modelContext: modelContext)
        
        XCTAssertTrue(report.repairedCount > 0, "データ修復が実行される必要があります")
        
        // 修復後の状態確認
        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)
        
        let repairedTask = tasks.first!
        XCTAssertTrue(repairedTask.isCompleted, "修復後は完了状態である必要があります")
        XCTAssertNotNil(repairedTask.completedAt, "修復後のcompletedAtが設定されている必要があります")
        
        if let completedAt = repairedTask.completedAt {
            XCTAssertLessThanOrEqual(completedAt.timeIntervalSinceNow, 1.0, "修復後の完了日時は現在時刻である必要があります")
        }
    }
    
    // MARK: - 包括的データ整合性テスト
    
    func testComprehensiveDataIntegrity() throws {
        // 複雑なデータセットを作成
        var tasks: [Task] = []
        
        for i in 1...10 {
            let task = Task(title: "包括的テストタスク \(i)")
            modelContext.insert(task)
            
            // ランダムなステップ数
            let stepCount = Int.random(in: 1...5)
            for j in 0..<stepCount {
                let step = TaskStep(order: j)
                step.task = task
                
                // ランダムな完了状態
                if Bool.random() {
                    step.isCompleted = true
                    step.completedAt = Date()
                }
                
                task.addStep(step)
                modelContext.insert(step)
            }
            
            // ランダムなタスク完了状態
            if Bool.random() {
                task.isCompleted = true
                task.completedAt = Date()
            }
            
            tasks.append(task)
        }
        
        try modelContext.save()
        
        // 包括的データ整合性チェック
        let report = DataIntegrityChecker.performComprehensiveCheck(modelContext: modelContext)
        
        XCTAssertTrue(report.isValid, "データ整合性に問題がない必要があります")
        XCTAssertEqual(report.issues.count, 0, "問題が0件である必要があります")
        XCTAssertEqual(report.repairedCount, 0, "修復件数は0である必要があります")
        XCTAssertEqual(report.totalTasks, 10, "総タスク数は10である必要があります")
        XCTAssertGreaterThan(report.totalSteps, 0, "総ステップ数は0より大きい必要があります")
    }
    
    func testDataIntegrityWithCorruptedData() throws {
        // 意図的に不整合なデータを作成
        let task1 = Task(title: "不整合タスク1")
        task1.isCompleted = true
        task1.completedAt = nil  // 不整合
        modelContext.insert(task1)
        
        let task2 = Task(title: "不整合タスク2")
        task2.isCompleted = false
        task2.completedAt = Date()  // 不整合
        modelContext.insert(task2)
        
        let task3 = Task(title: "不整合タスク3")
        task3.isCompleted = true
        task3.completedAt = Calendar.current.date(byAdding: .day, value: 1, to: Date())  // 未来
        modelContext.insert(task3)
        
        try modelContext.save()
        
        // 包括的データ整合性チェック
        let report = DataIntegrityChecker.performComprehensiveCheck(modelContext: modelContext)
        
        XCTAssertFalse(report.isValid, "データ整合性に問題がある必要があります")
        XCTAssertGreaterThan(report.issues.count, 0, "問題が検出される必要があります")
        XCTAssertGreaterThan(report.repairedCount, 0, "データ修復が実行される必要があります")
        
        // 修復後の再チェック
        let finalReport = DataIntegrityChecker.performComprehensiveCheck(modelContext: modelContext)
        XCTAssertTrue(finalReport.isValid, "修復後はデータ整合性に問題がない必要があります")
        XCTAssertEqual(finalReport.issues.count, 0, "修復後は問題が0件である必要があります")
    }
    
    // MARK: - パフォーマンステスト
    
    func testDataIntegrityPerformance() throws {
        // 大量のデータを作成
        let taskCount = 1000
        var tasks: [Task] = []
        
        for i in 1...taskCount {
            let task = Task(title: "パフォーマンステストタスク \(i)")
            modelContext.insert(task)
            
            // 各タスクにステップを追加
            for j in 0..<5 {
                let step = TaskStep(order: j)
                step.task = task
                task.addStep(step)
                modelContext.insert(step)
            }
            
            tasks.append(task)
        }
        
        try modelContext.save()
        
        // パフォーマンス測定
        measure {
            _ = DataIntegrityChecker.performComprehensiveCheck(modelContext: modelContext)
        }
        
        // 結果確認
        let report = DataIntegrityChecker.performComprehensiveCheck(modelContext: modelContext)
        XCTAssertTrue(report.isValid, "大量データでも整合性に問題がない必要があります")
        XCTAssertEqual(report.totalTasks, taskCount, "総タスク数が正しい必要があります")
        XCTAssertEqual(report.totalSteps, taskCount * 5, "総ステップ数が正しい必要があります")
    }
}