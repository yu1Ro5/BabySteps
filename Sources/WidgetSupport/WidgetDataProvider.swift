import Foundation
import SwiftData
import WidgetKit

private let appGroupID = "group.com.yu1Ro5.BabySteps"

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

// MARK: - UserDefaults Fallback（App Group の containerURL が nil でも UserDefaults は動作する場合がある）

/// SwiftData ストアにアクセスできない場合のフォールバック。アプリが UserDefaults に書き込んだデータをウィジェットが読む。
enum WidgetDataSync {
    private static let keyTodayCompleted = "widget_todayCompletedCount"
    private static let keyTodayTotal = "widget_todayTotalCount"
    private static let keyCompletedTasks = "widget_completedTasksCount"
    private static let keyTotalTasks = "widget_totalTasksCount"

    /// 進捗データを UserDefaults（App Group）に書き込む。アプリ側でデータ保存時に呼ぶ。
    static func writeToUserDefaults(entry: ProgressEntry) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        defaults.set(entry.todayCompletedCount, forKey: keyTodayCompleted)
        defaults.set(entry.todayTotalCount, forKey: keyTodayTotal)
        defaults.set(entry.completedTasksCount, forKey: keyCompletedTasks)
        defaults.set(entry.totalTasksCount, forKey: keyTotalTasks)
    }

    /// UserDefaults から進捗データを読み込む。ウィジェットで SwiftData が使えない場合のフォールバック。
    static func readFromUserDefaults(referenceDate: Date = Date()) -> ProgressEntry? {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return nil }
        let total = defaults.integer(forKey: keyTodayTotal)
        guard total > 0 else { return nil }
        return ProgressEntry(
            date: referenceDate,
            todayCompletedCount: defaults.integer(forKey: keyTodayCompleted),
            todayTotalCount: total,
            completedTasksCount: defaults.integer(forKey: keyCompletedTasks),
            totalTasksCount: defaults.integer(forKey: keyTotalTasks)
        )
    }
}
