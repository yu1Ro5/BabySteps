import Foundation
import SwiftData
import SwiftUI

@Observable
class TaskViewModel {
    let modelContext: ModelContext
    
    // アクティビティ更新の通知用
    var onActivityUpdate: (() -> Void)?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Task Management
    
    // 新しいタスクを作成
    func createTask(title: String) -> Task {
        let task = Task(title: title)
        modelContext.insert(task)
        try? modelContext.save()
        notifyActivityUpdate()
        return task
    }
    
    // タスクを削除
    func deleteTask(_ task: Task) {
        modelContext.delete(task)
        try? modelContext.save()
        notifyActivityUpdate()
    }
    
    // タスクのタイトルを更新
    func updateTaskTitle(_ task: Task, newTitle: String) {
        task.title = newTitle
        try? modelContext.save()
        notifyActivityUpdate()
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
        notifyActivityUpdate()
    }
    
    // ステップを削除
    func removeStep(_ step: TaskStep, from task: Task) {
        task.removeStep(step)
        modelContext.delete(step)
        try? modelContext.save()
        notifyActivityUpdate()
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
        
        // ステップ完了時は必ずアクティビティを更新
        notifyActivityUpdate()
        print("🔄 アクティビティ更新通知完了")
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
    

    
    // MARK: - Activity Update Notification
    
    // アクティビティ更新の通知
    private func notifyActivityUpdate() {
        onActivityUpdate?()
    }
}