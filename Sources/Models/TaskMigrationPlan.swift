import Foundation
import SwiftData

/// タスク完了機能追加のためのマイグレーションプラン
/// 既存のTaskモデルにisCompletedとcompletedAtプロパティを追加する
@Model
final class TaskMigrationPlan {
    /// マイグレーションの実行日時
    var executedAt: Date
    /// マイグレーションのバージョン
    var version: String
    /// マイグレーションの説明
    var description: String
    
    init(version: String, description: String) {
        self.executedAt = Date()
        self.version = version
        self.description = description
    }
    
    /// タスク完了機能のマイグレーションを実行
    static func executeTaskCompletionMigration(modelContext: ModelContext) -> Bool {
        print("🔄 タスク完了機能マイグレーション開始")
        
        do {
            // 既存のタスクを取得
            let descriptor = FetchDescriptor<Task>()
            let tasks = try modelContext.fetch(descriptor)
            
            print("📊 対象タスク数: \(tasks.count)")
            
            var migratedCount = 0
            
            for task in tasks {
                // 新しいプロパティが未設定の場合のみ設定
                if task.isCompleted == false && task.completedAt == nil {
                    // デフォルト値は既にinitで設定されているが、明示的に設定
                    task.isCompleted = false
                    task.completedAt = nil
                    migratedCount += 1
                    
                    print("✅ タスク「\(task.title)」をマイグレーション完了")
                }
            }
            
            // マイグレーション実行記録を作成
            let migrationRecord = TaskMigrationPlan(
                version: "1.0.0",
                description: "タスク完了機能追加 - isCompleted, completedAtプロパティ追加"
            )
            modelContext.insert(migrationRecord)
            
            // 変更を保存
            try modelContext.save()
            
            print("🎉 マイグレーション完了: \(migratedCount)件のタスクを処理")
            return true
            
        } catch {
            print("❌ マイグレーションエラー: \(error)")
            return false
        }
    }
    
    /// マイグレーションが必要かどうかをチェック
    static func isMigrationNeeded(modelContext: ModelContext) -> Bool {
        do {
            // マイグレーション実行記録を確認
            let descriptor = FetchDescriptor<TaskMigrationPlan>(
                predicate: #Predicate<TaskMigrationPlan> { plan in
                    plan.version == "1.0.0"
                }
            )
            let existingMigrations = try modelContext.fetch(descriptor)
            
            // 既にマイグレーションが実行済みの場合は不要
            return existingMigrations.isEmpty
            
        } catch {
            print("⚠️ マイグレーション確認エラー: \(error)")
            // エラーの場合は安全のためマイグレーションを実行
            return true
        }
    }
    
    /// データ整合性チェック
    static func validateDataIntegrity(modelContext: ModelContext) -> Bool {
        print("🔍 データ整合性チェック開始")
        
        do {
            let descriptor = FetchDescriptor<Task>()
            let tasks = try modelContext.fetch(descriptor)
            
            var isValid = true
            
            for task in tasks {
                // タスクの完了状態とcompletedAtの整合性をチェック
                if task.isCompleted && task.completedAt == nil {
                    print("⚠️ データ不整合: タスク「\(task.title)」が完了状態だがcompletedAtがnil")
                    isValid = false
                }
                
                if !task.isCompleted && task.completedAt != nil {
                    print("⚠️ データ不整合: タスク「\(task.title)」が未完了状態だがcompletedAtが設定済み")
                    isValid = false
                }
                
                // ステップの整合性もチェック
                for step in task.steps {
                    if step.isCompleted && step.completedAt == nil {
                        print("⚠️ データ不整合: タスク「\(task.title)」のステップ\(step.order + 1)が完了状態だがcompletedAtがnil")
                        isValid = false
                    }
                }
            }
            
            if isValid {
                print("✅ データ整合性チェック完了: 問題なし")
            } else {
                print("❌ データ整合性チェック完了: 問題あり")
            }
            
            return isValid
            
        } catch {
            print("❌ データ整合性チェックエラー: \(error)")
            return false
        }
    }
    
    /// データ修復
    static func repairData(modelContext: ModelContext) -> Bool {
        print("🔧 データ修復開始")
        
        do {
            let descriptor = FetchDescriptor<Task>()
            let tasks = try modelContext.fetch(descriptor)
            
            var repairedCount = 0
            
            for task in tasks {
                var needsRepair = false
                
                // タスクの完了状態とcompletedAtの整合性を修復
                if task.isCompleted && task.completedAt == nil {
                    task.completedAt = Date()
                    needsRepair = true
                    print("🔧 修復: タスク「\(task.title)」のcompletedAtを設定")
                }
                
                if !task.isCompleted && task.completedAt != nil {
                    task.completedAt = nil
                    needsRepair = true
                    print("🔧 修復: タスク「\(task.title)」のcompletedAtをクリア")
                }
                
                // ステップの整合性も修復
                for step in task.steps {
                    if step.isCompleted && step.completedAt == nil {
                        step.completedAt = Date()
                        needsRepair = true
                        print("🔧 修復: タスク「\(task.title)」のステップ\(step.order + 1)のcompletedAtを設定")
                    }
                    
                    if !step.isCompleted && step.completedAt != nil {
                        step.completedAt = nil
                        needsRepair = true
                        print("🔧 修復: タスク「\(task.title)」のステップ\(step.order + 1)のcompletedAtをクリア")
                    }
                }
                
                if needsRepair {
                    repairedCount += 1
                }
            }
            
            if repairedCount > 0 {
                try modelContext.save()
                print("🎉 データ修復完了: \(repairedCount)件のタスクを修復")
            } else {
                print("✅ データ修復完了: 修復不要")
            }
            
            return true
            
        } catch {
            print("❌ データ修復エラー: \(error)")
            return false
        }
    }
}