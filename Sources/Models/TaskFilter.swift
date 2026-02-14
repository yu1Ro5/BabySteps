import Foundation

/// タスク一覧のフィルター種別
enum TaskFilter: String, CaseIterable {
    case all = "すべて"
    case inProgress = "進行中"
    case completed = "完了"
}
