import Foundation
import SwiftData
import SwiftUI

@Observable
class TaskViewModel {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Task Management

    // 指定された数のステップを持つタスクを作成
    func createTaskWithSteps(title: String, stepCount: Int) -> Task {
        let tasks = (try? fetchTasks()) ?? []
        // Handle optional order values safely when computing the max
        let maxOrder = tasks.compactMap { $0.order }.max() ?? -1

        let task = Task(title: title)
        task.order = maxOrder + 1
        modelContext.insert(task)

        // 指定された数のステップを作成
        for i in 0..<stepCount {
            let step = TaskStep(order: i)
            step.task = task
            task.addStep(step)
            modelContext.insert(step)
        }

        try? modelContext.save()
        return task
    }

    // タスクを削除
    func deleteTask(_ task: Task) {
        modelContext.delete(task)
        try? modelContext.save()
    }

    // タスクのタイトルを更新
    func updateTaskTitle(_ task: Task, newTitle: String) {
        task.title = newTitle
        try? modelContext.save()
    }

    // MARK: - Step Management

    // タスクにステップを追加
    func addStep(to task: Task) {
        let order = task.steps.count
        let step = TaskStep(order: order)
        step.task = task
        task.addStep(step)
        modelContext.insert(step)
        try? modelContext.save()
    }

    // ステップを削除
    func removeStep(_ step: TaskStep, from task: Task) {
        task.removeStep(step)
        modelContext.delete(step)
        try? modelContext.save()
    }

    // ステップの完了状態を切り替え
    func toggleStepCompletion(_ step: TaskStep) {
        step.toggleCompletion()
        try? modelContext.save()
    }

    // MARK: - Reorder

    /// タスクの順序を変更する（filteredTasks のインデックスベース）
    func moveTasks(_ tasks: [Task], from source: IndexSet, to destination: Int) {
        var reordered = tasks
        reordered.move(fromOffsets: source, toOffset: destination)

        for (index, task) in reordered.enumerated() {
            task.order = index
        }
        try? modelContext.save()
    }

    // MARK: - Data Queries

    // 全タスクを取得
    func fetchTasks() throws -> [Task] {
        let descriptor = FetchDescriptor<Task>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    // 完了したタスクを取得
    func fetchCompletedTasks() throws -> [Task] {
        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate<Task> { task in
                task.steps.allSatisfy { $0.isCompleted }
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    // 進行中のタスクを取得
    func fetchInProgressTasks() throws -> [Task] {
        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate<Task> { task in
                !task.steps.allSatisfy { $0.isCompleted } && !task.steps.isEmpty
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
}
