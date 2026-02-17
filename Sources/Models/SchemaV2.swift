import Foundation
import SwiftData

enum SchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [SchemaV2.Task.self, SchemaV2.TaskStep.self]
    }
}

extension SchemaV2 {
    @Model
    final class Task: Identifiable {
        var id: UUID
        var title: String
        var createdAt: Date
        /// 表示順序（0から開始、小さいほど上に表示）。マイグレーション時はデフォルト 0 を使用。
        @Attribute(.defaultValue(0)) var order: Int
        var steps: [TaskStep]

        init(title: String) {
            self.id = UUID()
            self.title = title
            self.createdAt = Date()
            self.order = 0
            self.steps = []
        }

        var completedStepsCount: Int {
            steps.filter { $0.isCompleted }.count
        }

        var totalStepsCount: Int {
            steps.count
        }

        var isCompleted: Bool {
            !steps.isEmpty && steps.allSatisfy { $0.isCompleted }
        }

        func addStep(_ step: TaskStep) {
            steps.append(step)
            step.task = self
        }

        func removeStep(_ step: TaskStep) {
            if let index = steps.firstIndex(where: { $0.id == step.id }) {
                steps.remove(at: index)
                step.task = nil
            }
        }
    }

    @Model
    final class TaskStep {
        var id: UUID
        var isCompleted: Bool
        var order: Int
        var task: Task?
        var completedAt: Date?

        init(order: Int) {
            self.id = UUID()
            self.isCompleted = false
            self.order = order
            self.completedAt = nil
        }

        func toggleCompletion() {
            isCompleted.toggle()
            if isCompleted {
                completedAt = Date()
            }
            else {
                completedAt = nil
            }
        }
    }
}
