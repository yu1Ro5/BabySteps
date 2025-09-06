import Foundation
import SwiftData

/// データ整合性チェックとマイグレーション後の検証を行うクラス
class DataIntegrityChecker {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// アプリ起動時のデータ整合性チェック
    func performStartupChecks() {
        print("🔍 データ整合性チェック開始")
        
        // 1. Taskの基本プロパティチェック
        checkTaskProperties()
        
        // 2. TaskStepとの関連性チェック
        checkTaskStepRelationships()
        
        // 3. 孤立したオブジェクトのチェック
        checkOrphanedObjects()
        
        // 4. データの一貫性チェック
        checkDataConsistency()
        
        print("🔍 データ整合性チェック完了")
    }
    
    /// Taskの基本プロパティが正しく設定されているかチェック
    private func checkTaskProperties() {
        let descriptor = FetchDescriptor<Task>()
        let tasks = try? modelContext.fetch(descriptor)
        
        print("🔍 Taskプロパティチェック: \(tasks?.count ?? 0)件")
        
        tasks?.forEach { task in
            // 必須プロパティの存在チェック
            if task.title.isEmpty {
                print("⚠️ 警告: 空のタイトルを持つタスクが見つかりました (ID: \(task.id))")
            }
            
            // 新しいプロパティの存在チェック
            if task.isCompleted && task.completedAt == nil {
                print("⚠️ 警告: 完了済みタスクにcompletedAtが設定されていません (ID: \(task.id))")
                // 自動修正
                task.completedAt = Date()
                print("🔧 自動修正: completedAtを設定しました")
            }
            
            if !task.isCompleted && task.completedAt != nil {
                print("⚠️ 警告: 未完了タスクにcompletedAtが設定されています (ID: \(task.id))")
                // 自動修正
                task.completedAt = nil
                print("🔧 自動修正: completedAtをクリアしました")
            }
        }
        
        // 変更を保存
        try? modelContext.save()
    }
    
    /// TaskStepとの関連性をチェック
    private func checkTaskStepRelationships() {
        let descriptor = FetchDescriptor<TaskStep>()
        let steps = try? modelContext.fetch(descriptor)
        
        print("🔍 TaskStep関連性チェック: \(steps?.count ?? 0)件")
        
        steps?.forEach { step in
            // 孤立したTaskStepのチェック
            if step.task == nil {
                print("⚠️ 警告: 孤立したTaskStepが見つかりました (ID: \(step.id))")
                // 孤立したステップを削除
                modelContext.delete(step)
                print("🔧 自動修正: 孤立したTaskStepを削除しました")
            }
        }
        
        // 変更を保存
        try? modelContext.save()
    }
    
    /// 孤立したオブジェクトをチェック
    private func checkOrphanedObjects() {
        // TaskStepのtaskプロパティがnilのものをチェック
        let stepDescriptor = FetchDescriptor<TaskStep>(
            predicate: #Predicate<TaskStep> { step in
                step.task == nil
            }
        )
        
        let orphanedSteps = try? modelContext.fetch(stepDescriptor)
        
        if let orphanedCount = orphanedSteps?.count, orphanedCount > 0 {
            print("⚠️ 警告: \(orphanedCount)個の孤立したTaskStepが見つかりました")
            orphanedSteps?.forEach { step in
                modelContext.delete(step)
            }
            print("🔧 自動修正: 孤立したTaskStepを削除しました")
            try? modelContext.save()
        }
    }
    
    /// データの一貫性をチェック
    private func checkDataConsistency() {
        let descriptor = FetchDescriptor<Task>()
        let tasks = try? modelContext.fetch(descriptor)
        
        print("🔍 データ一貫性チェック: \(tasks?.count ?? 0)件")
        
        tasks?.forEach { task in
            // ステップの順序が正しいかチェック
            let sortedSteps = task.steps.sorted { $0.order < $1.order }
            let expectedOrder = Array(0..<task.steps.count)
            let actualOrder = sortedSteps.map { $0.order }
            
            if expectedOrder != actualOrder {
                print("⚠️ 警告: タスク「\(task.title)」のステップ順序が不正です")
                print("   期待: \(expectedOrder)")
                print("   実際: \(actualOrder)")
                
                // 順序を修正
                for (index, step) in sortedSteps.enumerated() {
                    step.order = index
                }
                print("🔧 自動修正: ステップ順序を修正しました")
            }
        }
        
        // 変更を保存
        try? modelContext.save()
    }
    
    /// マイグレーション後の統計情報を表示
    func printMigrationStatistics() {
        let taskDescriptor = FetchDescriptor<Task>()
        let tasks = try? modelContext.fetch(taskDescriptor)
        
        let completedTasks = tasks?.filter { $0.isCompleted }.count ?? 0
        let incompleteTasks = tasks?.filter { !$0.isCompleted }.count ?? 0
        
        print("📊 マイグレーション統計:")
        print("   総タスク数: \(tasks?.count ?? 0)")
        print("   完了済み: \(completedTasks)")
        print("   未完了: \(incompleteTasks)")
        
        let stepDescriptor = FetchDescriptor<TaskStep>()
        let steps = try? modelContext.fetch(stepDescriptor)
        let completedSteps = steps?.filter { $0.isCompleted }.count ?? 0
        
        print("   総ステップ数: \(steps?.count ?? 0)")
        print("   完了済みステップ: \(completedSteps)")
    }
}