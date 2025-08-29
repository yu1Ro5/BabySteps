import Foundation

struct DailyActivity {
    let date: Date
    let commitCount: Int
    let activityLevel: ActivityLevel
    let taskHistory: [TaskHistoryItem]
}

struct TaskHistoryItem {
    let taskId: UUID
    let taskTitle: String
    let stepOrder: Int
    let completedAt: Date
    let attemptCount: Int // そのタスクの何回目の着手か
}
