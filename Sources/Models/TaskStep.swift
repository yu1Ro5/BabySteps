import Foundation
import SwiftData

@Model
final class TaskStep {
    /// ステップの一意識別子
    var id: UUID
    /// ステップの完了状態
    var isCompleted: Bool
    /// ステップの表示順序（0から開始）
    var order: Int
    /// このステップが属するタスクへの参照
    var task: Task?
    /// ステップが完了した日時（完了していない場合はnil）
    var completedAt: Date?
    
    init(order: Int) {
        self.id = UUID()
        self.isCompleted = false
        self.order = order
        self.completedAt = nil
    }
    
    // ステップの完了状態を切り替え
    func toggleCompletion() {
        isCompleted.toggle()
        if isCompleted {
            completedAt = Date()
        } else {
            completedAt = nil
        }
    }
}
