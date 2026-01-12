import Foundation
import SwiftData

@Observable
class ActivityViewModel {
    private let modelContext: ModelContext

    // Viewの状態
    var dailyActivities: [DailyActivity] = []
    var isLoading = false
    var errorMessage: String?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Public Methods

    // 日別アクティビティを読み込み
    func loadDailyActivities(for days: Int = 90) {
        isLoading = true
        errorMessage = nil

        do {
            dailyActivities = try getDailyActivities(for: days)
        }
        catch {
            errorMessage = "アクティビティの読み込みに失敗しました: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // アクティビティを強制更新（外部から呼び出し可能）
    func refreshActivities() {
        loadDailyActivities()
    }

    // MARK: - Private Methods

    // 指定された日数分の日別アクティビティを取得
    private func getDailyActivities(for days: Int) throws -> [DailyActivity] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) ?? endDate
        let windowStart = calendar.startOfDay(for: startDate)

        // NOTE: SwiftData predicate does not support forced unwrap (!).
        // Fetch completed steps with a completion date, then filter by date range in memory.
        let predicate = #Predicate<TaskStep> { step in
            step.isCompleted && step.completedAt != nil
        }
        let descriptor = FetchDescriptor<TaskStep>(predicate: predicate)
        let steps = try modelContext.fetch(descriptor).filter { step in
            guard let completedAt = step.completedAt else { return false }
            return completedAt >= windowStart && completedAt <= endDate
        }

        var countsByDate: [Date: Int] = [:]
        countsByDate.reserveCapacity(days)
        for step in steps {
            guard let completedAt = step.completedAt else { continue }
            let dateKey = calendar.startOfDay(for: completedAt)
            countsByDate[dateKey, default: 0] += 1
        }

        var activities: [DailyActivity] = []
        activities.reserveCapacity(days + 1)

        var currentDate = windowStart
        while currentDate <= endDate {
            let dateKey = calendar.startOfDay(for: currentDate)
            let commitCount = countsByDate[dateKey] ?? 0
            let level = calculateActivityLevel(commitCount)

            activities.append(
                DailyActivity(
                    date: currentDate,
                    commitCount: commitCount,
                    activityLevel: level
                ))

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return activities
    }

    // コミット数からアクティビティレベルを計算
    private func calculateActivityLevel(_ commitCount: Int) -> ActivityLevel {
        switch commitCount {
        case 0: return .none
        case 1...3: return .low
        case 4...6: return .medium
        case 7...9: return .high
        default: return .veryHigh
        }
    }
}
