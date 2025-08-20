import Foundation
import SwiftData

@Model
final class Task {
    var id: UUID
    var title: String
    var createdAt: Date
    var steps: [TaskStep]
    
    init(title: String) {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.steps = []
    }
    
    // 進捗率を計算（完了したステップ数 / 全ステップ数）
    var progress: Double {
        guard !steps.isEmpty else { return 0.0 }
        let completedSteps = steps.filter { $0.isCompleted }.count
        return Double(completedSteps) / Double(steps.count)
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
    }
    
    // ステップを削除
    func removeStep(_ step: TaskStep) {
        if let index = steps.firstIndex(where: { $0.id == step.id }) {
            steps.remove(at: index)
        }
    }
}

@Model
final class TaskStep {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var order: Int
    var task: Task?
    
    init(title: String, order: Int) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.order = order
    }
    
    // ステップの完了状態を切り替え
    func toggleCompletion() {
        isCompleted.toggle()
    }
}