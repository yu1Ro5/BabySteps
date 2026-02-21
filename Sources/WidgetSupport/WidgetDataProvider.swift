import Foundation
import SwiftData
import WidgetKit

// MARK: - Progress Entry

/// ウィジェット用の進捗データ。TimelineEntry に準拠。
struct ProgressEntry: TimelineEntry {
    let date: Date
    let todayCompletedCount: Int
    let todayTotalCount: Int
    let completedTasksCount: Int
    let totalTasksCount: Int
}

// MARK: - Widget Data Provider

/// ウィジェット表示用の進捗データを取得する。テスト可能な純粋なロジック。
enum WidgetDataProvider {
    /// ModelContext から進捗データを取得する。
    /// - Parameters:
    ///   - context: SwiftData の ModelContext
    ///   - referenceDate: 「今日」として扱う基準日（テスト用に注入可能）
    /// - Returns: 進捗データ
    static func fetchProgress(context: ModelContext, referenceDate: Date = Date()) -> ProgressEntry {
        let calendar = Calendar.current

        let completedStepsDescriptor = FetchDescriptor<SchemaV2.TaskStep>(
            predicate: #Predicate<SchemaV2.TaskStep> { step in
                step.isCompleted && step.completedAt != nil
            }
        )
        let allCompletedSteps = (try? context.fetch(completedStepsDescriptor)) ?? []
        let todayCompletedSteps = allCompletedSteps.filter { step in
            guard let completedAt = step.completedAt else { return false }
            return calendar.isDate(completedAt, inSameDayAs: referenceDate)
        }

        let tasksDescriptor = FetchDescriptor<SchemaV2.Task>(
            sortBy: [SortDescriptor(\.order, order: .forward)]
        )
        let tasks = (try? context.fetch(tasksDescriptor)) ?? []

        let totalSteps = tasks.flatMap(\.steps).count
        let completedTasks = tasks.filter { $0.isCompleted }.count

        return ProgressEntry(
            date: referenceDate,
            todayCompletedCount: todayCompletedSteps.count,
            todayTotalCount: totalSteps,
            completedTasksCount: completedTasks,
            totalTasksCount: tasks.count
        )
    }
}
