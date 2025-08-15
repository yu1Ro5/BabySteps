import Foundation
import SwiftData
import SwiftUI

@Observable
class TaskViewModel {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Task Management
    
    // 新しいタスクを作成
    func createTask(title: String) -> Task {
        let task = Task(title: title)
        modelContext.insert(task)
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
    func addStep(to task: Task, stepTitle: String) {
        let order = task.steps.count
        let step = TaskStep(title: stepTitle, order: order)
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
    
    // ステップのタイトルを更新
    func updateStepTitle(_ step: TaskStep, newTitle: String) {
        step.title = newTitle
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
    
    // MARK: - Progress Management
    
    // タスクの進捗率を取得
    func getTaskProgress(_ task: Task) -> Double {
        return task.progress
    }
    
    // 全体的な進捗率を計算
    func getOverallProgress() throws -> Double {
        let tasks = try fetchTasks()
        guard !tasks.isEmpty else { return 0.0 }
        
        let totalProgress = tasks.reduce(0.0) { $0 + $1.progress }
        return totalProgress / Double(tasks.count)
    }
}