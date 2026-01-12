import SwiftData
import SwiftUI

struct ActivityView: View {
    private let daysWindow: Int
    private let windowStart: Date

    @Query private var completedSteps: [TaskStep]
    @State private var dailyActivities: [DailyActivity] = []

    init(daysWindow: Int = 90) {
        self.daysWindow = daysWindow

        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -daysWindow, to: endDate) ?? endDate
        let windowStart = calendar.startOfDay(for: startDate)
        self.windowStart = windowStart

        _completedSteps = Query(
            filter: #Predicate<TaskStep> { step in
                // NOTE: SwiftData predicate does not support forced unwrap (!).
                // We only filter by completion here, and apply the date-window filter during aggregation.
                step.isCompleted && step.completedAt != nil
            },
            sort: [SortDescriptor(\TaskStep.completedAt, order: .forward)]
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // カレンダーグリッド
                if dailyActivities.isEmpty {
                    ProgressView("アクティビティを読み込み中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else {
                    CalendarGridView(activities: dailyActivities)
                }

                Spacer()
            }
            .navigationTitle("アクティビティ")
            .onAppear {
                recalculateDailyActivities()
            }
            .onChange(of: completedSteps) { _, newSteps in
                _ = newSteps  // 明示的に依存関係を残す
                recalculateDailyActivities()
            }
        }
    }

    // MARK: - Private Methods

    private func recalculateDailyActivities() {
        dailyActivities = getDailyActivities(for: daysWindow)
    }

    // 指定された日数分の日別アクティビティを取得（フェッチ結果を集計して生成）
    private func getDailyActivities(for days: Int) -> [DailyActivity] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) ?? endDate
        let startOfWindow = max(windowStart, calendar.startOfDay(for: startDate))

        // 完了済みステップを日付別に集計
        let countsByDate = countStepsByDate(completedSteps)

        var activities: [DailyActivity] = []
        var currentDate = startOfWindow

        while currentDate <= endDate {
            let dateKey = calendar.startOfDay(for: currentDate)
            let commitCount = countsByDate[dateKey] ?? 0
            let level = calculateActivityLevel(commitCount)

            let activity = DailyActivity(
                date: currentDate,
                commitCount: commitCount,
                activityLevel: level
            )

            activities.append(activity)

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return activities
    }

    private func countStepsByDate(_ steps: [TaskStep]) -> [Date: Int] {
        let calendar = Calendar.current
        var counts: [Date: Int] = [:]

        for step in steps {
            guard let completedAt = step.completedAt else { continue }
            guard completedAt >= windowStart else { continue }
            let dateKey = calendar.startOfDay(for: completedAt)
            counts[dateKey, default: 0] += 1
        }

        return counts
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
