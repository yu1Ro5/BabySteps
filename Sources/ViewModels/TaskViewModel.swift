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
        let task = Task(title: title)
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current

        print("🔄 ステップ完了状態切り替え開始: ステップ\(step.order + 1)")
        print("🔄 現在の状態: isCompleted=\(step.isCompleted), completedAt=\(step.completedAt?.description ?? "nil")")

        step.toggleCompletion()

        print("🔄 切り替え後の状態: isCompleted=\(step.isCompleted), completedAt=\(step.completedAt?.description ?? "nil")")

        try? modelContext.save()
        print("🔄 データベース保存完了")
    }
    
    // タスク全体の完了状態を切り替え
    func toggleTaskCompletion(_ task: Task) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current

        print("🔄 タスク完了状態切り替え開始: \(task.title)")
        print("🔄 現在の状態: isCompleted=\(task.isCompleted), completedAt=\(task.completedAt?.description ?? "nil")")

        task.toggleCompletion()

        print("🔄 切り替え後の状態: isCompleted=\(task.isCompleted), completedAt=\(task.completedAt?.description ?? "nil")")

        try? modelContext.save()
        print("🔄 データベース保存完了")
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
