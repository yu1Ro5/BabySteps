import Foundation
import SwiftData

@Model
final class TaskStep {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var order: Int
    var task: Task?
    var completedAt: Date?
    
    init(title: String, order: Int) {
        self.id = UUID()
        self.title = title
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