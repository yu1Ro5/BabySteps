import Foundation
import SwiftData

/// データ整合性チェックと修復を行うユーティリティクラス
final class DataIntegrityChecker {
    
    /// データ整合性の詳細レポート
    struct IntegrityReport {
        let isValid: Bool
        let issues: [String]
        let repairedCount: Int
        let totalTasks: Int
        let totalSteps: Int
    }
    
    /// 包括的なデータ整合性チェックを実行
    static func performComprehensiveCheck(modelContext: ModelContext) -> IntegrityReport {
        print("🔍 包括的データ整合性チェック開始")
        
        var issues: [String] = []
        var repairedCount = 0
        
        do {
            // タスクとステップを取得
            let taskDescriptor = FetchDescriptor<Task>()
            let tasks = try modelContext.fetch(taskDescriptor)
            
            let stepDescriptor = FetchDescriptor<TaskStep>()
            let steps = try modelContext.fetch(stepDescriptor)
            
            print("📊 チェック対象: タスク\(tasks.count)件、ステップ\(steps.count)件")
            
            // タスクの整合性チェック
            for task in tasks {
                let taskIssues = checkTaskIntegrity(task)
                issues.append(contentsOf: taskIssues)
                
                // 自動修復
                if !taskIssues.isEmpty {
                    repairedCount += repairTaskIssues(task)
                }
            }
            
            // ステップの整合性チェック
            for step in steps {
                let stepIssues = checkStepIntegrity(step)
                issues.append(contentsOf: stepIssues)
                
                // 自動修復
                if !stepIssues.isEmpty {
                    repairedCount += repairStepIssues(step)
                }
            }
            
            // 関連性の整合性チェック
            let relationshipIssues = checkRelationshipIntegrity(tasks: tasks, steps: steps)
            issues.append(contentsOf: relationshipIssues)
            
            // 修復があった場合は保存
            if repairedCount > 0 {
                try modelContext.save()
                print("💾 修復結果を保存")
            }
            
            let report = IntegrityReport(
                isValid: issues.isEmpty,
                issues: issues,
                repairedCount: repairedCount,
                totalTasks: tasks.count,
                totalSteps: steps.count
            )
            
            printReport(report)
            return report
            
        } catch {
            print("❌ データ整合性チェックエラー: \(error)")
            return IntegrityReport(
                isValid: false,
                issues: ["データベースアクセスエラー: \(error.localizedDescription)"],
                repairedCount: 0,
                totalTasks: 0,
                totalSteps: 0
            )
        }
    }
    
    /// タスクの整合性をチェック
    private static func checkTaskIntegrity(_ task: Task) -> [String] {
        var issues: [String] = []
        
        // 必須フィールドのチェック
        if task.title.isEmpty {
            issues.append("タスク「\(task.id)」のタイトルが空です")
        }
        
        if task.createdAt > Date() {
            issues.append("タスク「\(task.title)」の作成日時が未来です")
        }
        
        // 完了状態の整合性チェック
        if task.isCompleted && task.completedAt == nil {
            issues.append("タスク「\(task.title)」が完了状態だがcompletedAtがnilです")
        }
        
        if !task.isCompleted && task.completedAt != nil {
            issues.append("タスク「\(task.title)」が未完了状態だがcompletedAtが設定されています")
        }
        
        // 完了日時の論理性チェック
        if let completedAt = task.completedAt {
            if completedAt < task.createdAt {
                issues.append("タスク「\(task.title)」の完了日時が作成日時より前です")
            }
            
            if completedAt > Date() {
                issues.append("タスク「\(task.title)」の完了日時が未来です")
            }
        }
        
        return issues
    }
    
    /// ステップの整合性をチェック
    private static func checkStepIntegrity(_ step: TaskStep) -> [String] {
        var issues: [String] = []
        
        // 完了状態の整合性チェック
        if step.isCompleted && step.completedAt == nil {
            issues.append("ステップ\(step.order + 1)が完了状態だがcompletedAtがnilです")
        }
        
        if !step.isCompleted && step.completedAt != nil {
            issues.append("ステップ\(step.order + 1)が未完了状態だがcompletedAtが設定されています")
        }
        
        // 完了日時の論理性チェック
        if let completedAt = step.completedAt {
            if completedAt > Date() {
                issues.append("ステップ\(step.order + 1)の完了日時が未来です")
            }
        }
        
        return issues
    }
    
    /// 関連性の整合性をチェック
    private static func checkRelationshipIntegrity(tasks: [Task], steps: [TaskStep]) -> [String] {
        var issues: [String] = []
        
        // 孤立したステップのチェック
        for step in steps {
            if step.task == nil {
                issues.append("ステップ\(step.order + 1)がタスクに紐づいていません")
            }
        }
        
        // タスクとステップの関連性チェック
        for task in tasks {
            for step in task.steps {
                if step.task?.id != task.id {
                    issues.append("タスク「\(task.title)」のステップ\(step.order + 1)の関連性が不正です")
                }
            }
        }
        
        return issues
    }
    
    /// タスクの問題を修復
    private static func repairTaskIssues(_ task: Task) -> Int {
        var repairedCount = 0
        
        // 完了状態の修復
        if task.isCompleted && task.completedAt == nil {
            task.completedAt = Date()
            repairedCount += 1
            print("🔧 修復: タスク「\(task.title)」のcompletedAtを設定")
        }
        
        if !task.isCompleted && task.completedAt != nil {
            task.completedAt = nil
            repairedCount += 1
            print("🔧 修復: タスク「\(task.title)」のcompletedAtをクリア")
        }
        
        // 完了日時の論理性修復
        if let completedAt = task.completedAt {
            if completedAt < task.createdAt {
                task.completedAt = task.createdAt
                repairedCount += 1
                print("🔧 修復: タスク「\(task.title)」の完了日時を修正")
            }
            
            if completedAt > Date() {
                task.completedAt = Date()
                repairedCount += 1
                print("🔧 修復: タスク「\(task.title)」の完了日時を現在時刻に修正")
            }
        }
        
        return repairedCount
    }
    
    /// ステップの問題を修復
    private static func repairStepIssues(_ step: TaskStep) -> Int {
        var repairedCount = 0
        
        // 完了状態の修復
        if step.isCompleted && step.completedAt == nil {
            step.completedAt = Date()
            repairedCount += 1
            print("🔧 修復: ステップ\(step.order + 1)のcompletedAtを設定")
        }
        
        if !step.isCompleted && step.completedAt != nil {
            step.completedAt = nil
            repairedCount += 1
            print("🔧 修復: ステップ\(step.order + 1)のcompletedAtをクリア")
        }
        
        // 完了日時の論理性修復
        if let completedAt = step.completedAt {
            if completedAt > Date() {
                step.completedAt = Date()
                repairedCount += 1
                print("🔧 修復: ステップ\(step.order + 1)の完了日時を現在時刻に修正")
            }
        }
        
        return repairedCount
    }
    
    /// レポートを出力
    private static func printReport(_ report: IntegrityReport) {
        print("📋 データ整合性チェック結果:")
        print("   - 総タスク数: \(report.totalTasks)")
        print("   - 総ステップ数: \(report.totalSteps)")
        print("   - 整合性: \(report.isValid ? "✅ 正常" : "❌ 問題あり")")
        print("   - 修復件数: \(report.repairedCount)")
        
        if !report.issues.isEmpty {
            print("   - 発見された問題:")
            for issue in report.issues {
                print("     • \(issue)")
            }
        }
        
        if report.repairedCount > 0 {
            print("   - 自動修復: \(report.repairedCount)件のデータを修復しました")
        }
    }
    
    /// 簡易チェック（パフォーマンス重視）
    static func performQuickCheck(modelContext: ModelContext) -> Bool {
        print("⚡ 簡易データ整合性チェック開始")
        
        do {
            let descriptor = FetchDescriptor<Task>()
            let tasks = try modelContext.fetch(descriptor)
            
            for task in tasks {
                // 基本的な整合性のみチェック
                if task.isCompleted && task.completedAt == nil {
                    print("⚠️ 簡易チェック: タスク「\(task.title)」の完了状態に不整合")
                    return false
                }
                
                if !task.isCompleted && task.completedAt != nil {
                    print("⚠️ 簡易チェック: タスク「\(task.title)」の完了状態に不整合")
                    return false
                }
            }
            
            print("✅ 簡易チェック完了: 問題なし")
            return true
            
        } catch {
            print("❌ 簡易チェックエラー: \(error)")
            return false
        }
    }
}