import Foundation
import SwiftData

@Model
final class Task {
    /// タスクの一意識別子
    var id: UUID
    /// タスクのタイトル
    var title: String
    /// タスクの作成日時
    var createdAt: Date
    /// タスクに紐づくステップの配列
    var steps: [TaskStep]
    /// タスク全体の完了状態
    var isCompleted: Bool
    /// タスクが完了した日時（完了していない場合はnil）
    var completedAt: Date?

    init(title: String) {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.steps = []
        self.isCompleted = false
        self.completedAt = nil
    }

    // 完了したステップ数を取得
    var completedStepsCount: Int {
        steps.filter { $0.isCompleted }.count
    }

    // 全ステップ数を取得
    var totalStepsCount: Int {
        steps.count
    }

    // ステップを追加
    func addStep(_ step: TaskStep) {
        steps.append(step)
        step.task = self
    }

    // ステップを削除
    func removeStep(_ step: TaskStep) {
        if let index = steps.firstIndex(where: { $0.id == step.id }) {
            steps.remove(at: index)
            step.task = nil
        }
    }
    
    // タスク全体の完了状態を切り替え
    func toggleCompletion() {
        isCompleted.toggle()
        if isCompleted {
            completedAt = Date()
        } else {
            completedAt = nil
        }
    }
}
