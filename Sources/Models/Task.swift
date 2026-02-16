import Foundation
import SwiftData

@Model
final class Task: Identifiable {
    /// タスクの一意識別子
    var id: UUID
    /// タスクのタイトル
    var title: String
    /// タスクの作成日時
    var createdAt: Date
    /// 表示順序（0から開始、小さいほど上に表示）
    var order: Int?
    /// タスクに紐づくステップの配列
    var steps: [TaskStep]

    init(title: String) {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.order = 0
        self.steps = []
    }

    // 完了したステップ数を取得
    var completedStepsCount: Int {
        steps.filter { $0.isCompleted }.count
    }

    // 全ステップ数を取得
    var totalStepsCount: Int {
        steps.count
    }

    /// タスクが完了状態か（ステップが1つ以上かつ全ステップ完了）
    var isCompleted: Bool {
        !steps.isEmpty && steps.allSatisfy { $0.isCompleted }
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

    static func migrateOrderIfNeeded(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Task>(predicate: #Predicate<Task> { $0.order == nil })
        if let tasksNeedingOrder = try? modelContext.fetch(descriptor), !tasksNeedingOrder.isEmpty {
            for task in tasksNeedingOrder { task.order = 0 }
            try? modelContext.save()
        }
    }
}

/// This migration pattern allows safe updating of the optional `order` property 
/// for existing Task objects in code-based SwiftData setups.
