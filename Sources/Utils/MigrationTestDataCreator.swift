import Foundation
import SwiftData

/// マイグレーションテスト用のサンプルデータを作成するクラス
class MigrationTestDataCreator {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// マイグレーションテスト用のサンプルデータを作成
    func createTestData() {
        print("🧪 マイグレーションテスト用データ作成開始")
        
        // 既存データをクリア（テスト用）
        clearExistingData()
        
        // サンプルタスクを作成
        createSampleTasks()
        
        print("🧪 テストデータ作成完了")
    }
    
    /// 既存データをクリア（テスト用）
    private func clearExistingData() {
        let taskDescriptor = FetchDescriptor<Task>()
        let tasks = try? modelContext.fetch(taskDescriptor)
        
        tasks?.forEach { task in
            modelContext.delete(task)
        }
        
        let stepDescriptor = FetchDescriptor<TaskStep>()
        let steps = try? modelContext.fetch(stepDescriptor)
        
        steps?.forEach { step in
            modelContext.delete(step)
        }
        
        try? modelContext.save()
        print("🧪 既存データをクリアしました")
    }
    
    /// サンプルタスクを作成
    private func createSampleTasks() {
        // タスク1: 未完了のタスク
        let task1 = Task(title: "読書習慣を身につける")
        modelContext.insert(task1)
        
        for i in 0..<3 {
            let step = TaskStep(order: i)
            step.task = task1
            task1.addStep(step)
            modelContext.insert(step)
        }
        
        // タスク2: 一部完了のタスク
        let task2 = Task(title: "ジム通いを習慣化")
        modelContext.insert(task2)
        
        for i in 0..<5 {
            let step = TaskStep(order: i)
            step.task = task2
            task2.addStep(step)
            modelContext.insert(step)
            
            // 最初の2つのステップを完了にする
            if i < 2 {
                step.toggleCompletion()
            }
        }
        
        // タスク3: 空のタスク
        let task3 = Task(title: "新しいプロジェクトを始める")
        modelContext.insert(task3)
        
        try? modelContext.save()
        print("🧪 サンプルタスクを作成しました")
        print("   - 未完了タスク: 1件")
        print("   - 一部完了タスク: 1件")
        print("   - 空タスク: 1件")
    }
    
    /// マイグレーション前のデータ状態をシミュレート
    func simulatePreMigrationState() {
        print("🧪 マイグレーション前の状態をシミュレート")
        
        // 既存のTaskオブジェクトのisCompletedプロパティを一時的に無効化
        // （実際のマイグレーションでは、この状態から新しいプロパティが追加される）
        
        let descriptor = FetchDescriptor<Task>()
        let tasks = try? modelContext.fetch(descriptor)
        
        tasks?.forEach { task in
            // マイグレーション前はisCompletedプロパティが存在しない状態をシミュレート
            print("🧪 マイグレーション前のタスク: \(task.title)")
            print("   - ステップ数: \(task.steps.count)")
            print("   - 完了ステップ数: \(task.completedStepsCount)")
        }
    }
}