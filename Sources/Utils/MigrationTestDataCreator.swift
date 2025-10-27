import Foundation
import SwiftData

/// マイグレーションテスト用のデータを作成するユーティリティクラス
final class MigrationTestDataCreator {
    
    /// テストデータの種類
    enum TestDataType {
        case basic           // 基本的なテストデータ
        case mixed          // 完了/未完了が混在
        case edgeCases      // エッジケース
        case largeDataset   // 大量データ
        case corrupted      // 意図的に不整合なデータ
    }
    
    /// 指定されたタイプのテストデータを作成
    static func createTestData(
        type: TestDataType,
        modelContext: ModelContext,
        count: Int = 10
    ) -> [Task] {
        print("🧪 テストデータ作成開始: \(type), 件数: \(count)")
        
        var tasks: [Task] = []
        
        switch type {
        case .basic:
            tasks = createBasicTestData(modelContext: modelContext, count: count)
        case .mixed:
            tasks = createMixedTestData(modelContext: modelContext, count: count)
        case .edgeCases:
            tasks = createEdgeCaseTestData(modelContext: modelContext, count: count)
        case .largeDataset:
            tasks = createLargeDatasetTestData(modelContext: modelContext, count: count)
        case .corrupted:
            tasks = createCorruptedTestData(modelContext: modelContext, count: count)
        }
        
        // データを保存
        do {
            try modelContext.save()
            print("💾 テストデータ保存完了: \(tasks.count)件")
        } catch {
            print("❌ テストデータ保存エラー: \(error)")
        }
        
        return tasks
    }
    
    /// 基本的なテストデータを作成
    private static func createBasicTestData(modelContext: ModelContext, count: Int) -> [Task] {
        var tasks: [Task] = []
        
        for i in 1...count {
            let task = Task(title: "基本テストタスク \(i)")
            modelContext.insert(task)
            
            // 3-7個のステップを追加
            let stepCount = Int.random(in: 3...7)
            for j in 0..<stepCount {
                let step = TaskStep(order: j)
                step.task = task
                task.addStep(step)
                modelContext.insert(step)
            }
            
            tasks.append(task)
        }
        
        return tasks
    }
    
    /// 完了/未完了が混在するテストデータを作成
    private static func createMixedTestData(modelContext: ModelContext, count: Int) -> [Task] {
        var tasks: [Task] = []
        
        for i in 1...count {
            let task = Task(title: "混在テストタスク \(i)")
            modelContext.insert(task)
            
            // タスクの完了状態をランダムに設定
            if Bool.random() {
                task.isCompleted = true
                task.completedAt = Date()
            }
            
            // 5個のステップを追加
            for j in 0..<5 {
                let step = TaskStep(order: j)
                step.task = task
                
                // ステップの完了状態をランダムに設定
                if Bool.random() {
                    step.isCompleted = true
                    step.completedAt = Date()
                }
                
                task.addStep(step)
                modelContext.insert(step)
            }
            
            tasks.append(task)
        }
        
        return tasks
    }
    
    /// エッジケースのテストデータを作成
    private static func createEdgeCaseTestData(modelContext: ModelContext, count: Int) -> [Task] {
        var tasks: [Task] = []
        
        // 空のタスク
        let emptyTask = Task(title: "空のタスク")
        modelContext.insert(emptyTask)
        tasks.append(emptyTask)
        
        // ステップが1つのタスク
        let singleStepTask = Task(title: "ステップ1つのタスク")
        modelContext.insert(singleStepTask)
        let step = TaskStep(order: 0)
        step.task = singleStepTask
        singleStepTask.addStep(step)
        modelContext.insert(step)
        tasks.append(singleStepTask)
        
        // 全ステップ完了のタスク
        let allCompletedTask = Task(title: "全ステップ完了タスク")
        modelContext.insert(allCompletedTask)
        for j in 0..<3 {
            let step = TaskStep(order: j)
            step.task = allCompletedTask
            step.isCompleted = true
            step.completedAt = Date()
            allCompletedTask.addStep(step)
            modelContext.insert(step)
        }
        tasks.append(allCompletedTask)
        
        // 長いタイトルのタスク
        let longTitleTask = Task(title: "これは非常に長いタイトルのタスクです。テスト用に作成されたこのタスクは、UIの表示がどのように動作するかを確認するために使用されます。")
        modelContext.insert(longTitleTask)
        for j in 0..<2 {
            let step = TaskStep(order: j)
            step.task = longTitleTask
            longTitleTask.addStep(step)
            modelContext.insert(step)
        }
        tasks.append(longTitleTask)
        
        // 残りのタスクを作成
        for i in 1...(count - 4) {
            let task = Task(title: "エッジケースタスク \(i)")
            modelContext.insert(task)
            
            // ランダムなステップ数（0-10）
            let stepCount = Int.random(in: 0...10)
            for j in 0..<stepCount {
                let step = TaskStep(order: j)
                step.task = task
                task.addStep(step)
                modelContext.insert(step)
            }
            
            tasks.append(task)
        }
        
        return tasks
    }
    
    /// 大量データのテストデータを作成
    private static func createLargeDatasetTestData(modelContext: ModelContext, count: Int) -> [Task] {
        var tasks: [Task] = []
        
        for i in 1...count {
            let task = Task(title: "大量データタスク \(i)")
            modelContext.insert(task)
            
            // 多くのステップを追加（10-20個）
            let stepCount = Int.random(in: 10...20)
            for j in 0..<stepCount {
                let step = TaskStep(order: j)
                step.task = task
                
                // ランダムに完了状態を設定
                if Bool.random() {
                    step.isCompleted = true
                    step.completedAt = Date()
                }
                
                task.addStep(step)
                modelContext.insert(step)
            }
            
            // タスクの完了状態もランダムに設定
            if Bool.random() {
                task.isCompleted = true
                task.completedAt = Date()
            }
            
            tasks.append(task)
        }
        
        return tasks
    }
    
    /// 意図的に不整合なデータを作成
    private static func createCorruptedTestData(modelContext: ModelContext, count: Int) -> [Task] {
        var tasks: [Task] = []
        
        for i in 1...count {
            let task = Task(title: "不整合データタスク \(i)")
            modelContext.insert(task)
            
            // 意図的に不整合な状態を作成
            switch i % 4 {
            case 0:
                // 完了状態だがcompletedAtがnil
                task.isCompleted = true
                task.completedAt = nil
            case 1:
                // 未完了状態だがcompletedAtが設定済み
                task.isCompleted = false
                task.completedAt = Date()
            case 2:
                // 完了日時が未来
                task.isCompleted = true
                task.completedAt = Calendar.current.date(byAdding: .day, value: 1, to: Date())
            case 3:
                // 完了日時が作成日時より前
                task.isCompleted = true
                task.completedAt = Calendar.current.date(byAdding: .day, value: -1, to: task.createdAt)
            default:
                break
            }
            
            // ステップも不整合に設定
            for j in 0..<3 {
                let step = TaskStep(order: j)
                step.task = task
                
                // ステップも意図的に不整合に設定
                if j % 2 == 0 {
                    step.isCompleted = true
                    step.completedAt = nil
                } else {
                    step.isCompleted = false
                    step.completedAt = Date()
                }
                
                task.addStep(step)
                modelContext.insert(step)
            }
            
            tasks.append(task)
        }
        
        return tasks
    }
    
    /// 既存のテストデータをクリア
    static func clearTestData(modelContext: ModelContext) {
        print("🗑️ テストデータクリア開始")
        
        do {
            // タスクを削除
            let taskDescriptor = FetchDescriptor<Task>()
            let tasks = try modelContext.fetch(taskDescriptor)
            
            for task in tasks {
                modelContext.delete(task)
            }
            
            // ステップを削除
            let stepDescriptor = FetchDescriptor<TaskStep>()
            let steps = try modelContext.fetch(stepDescriptor)
            
            for step in steps {
                modelContext.delete(step)
            }
            
            // マイグレーション記録を削除
            let migrationDescriptor = FetchDescriptor<TaskMigrationPlan>()
            let migrations = try modelContext.fetch(migrationDescriptor)
            
            for migration in migrations {
                modelContext.delete(migration)
            }
            
            try modelContext.save()
            print("✅ テストデータクリア完了")
            
        } catch {
            print("❌ テストデータクリアエラー: \(error)")
        }
    }
    
    /// テストデータの統計情報を出力
    static func printTestDataStatistics(modelContext: ModelContext) {
        print("📊 テストデータ統計情報:")
        
        do {
            let taskDescriptor = FetchDescriptor<Task>()
            let tasks = try modelContext.fetch(taskDescriptor)
            
            let stepDescriptor = FetchDescriptor<TaskStep>()
            let steps = try modelContext.fetch(stepDescriptor)
            
            let completedTasks = tasks.filter { $0.isCompleted }
            let completedSteps = steps.filter { $0.isCompleted }
            
            print("   - 総タスク数: \(tasks.count)")
            print("   - 完了タスク数: \(completedTasks.count)")
            print("   - 未完了タスク数: \(tasks.count - completedTasks.count)")
            print("   - 総ステップ数: \(steps.count)")
            print("   - 完了ステップ数: \(completedSteps.count)")
            print("   - 未完了ステップ数: \(steps.count - completedSteps.count)")
            
            // タスクごとのステップ数分布
            let stepCounts = tasks.map { $0.steps.count }
            if let maxSteps = stepCounts.max(), let minSteps = stepCounts.min() {
                print("   - ステップ数範囲: \(minSteps) - \(maxSteps)")
            }
            
        } catch {
            print("❌ 統計情報取得エラー: \(error)")
        }
    }
}