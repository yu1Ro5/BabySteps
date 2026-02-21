import SwiftData
import SwiftUI
import WidgetKit

// MARK: - Timeline Entry

struct ProgressEntry: TimelineEntry {
    let date: Date
    let todayCompletedCount: Int
    let todayTotalCount: Int
    let completedTasksCount: Int
    let totalTasksCount: Int
}

// MARK: - Timeline Provider

struct ProgressTimelineProvider: TimelineProvider {
    private let appGroupID = "group.com.yu1Ro5.BabySteps"

    private var modelContainer: ModelContainer? {
        guard let containerURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
        else { return nil }

        let storeURL = containerURL.appendingPathComponent("default.store")
        let schema = Schema(versionedSchema: SchemaLatest.self)
        let config = ModelConfiguration(schema: schema, url: storeURL)

        return try? ModelContainer(for: schema, migrationPlan: BabyStepsMigrationPlan.self, configurations: [config])
    }

    func placeholder(in _: Context) -> ProgressEntry {
        ProgressEntry(
            date: Date(),
            todayCompletedCount: 3,
            todayTotalCount: 10,
            completedTasksCount: 1,
            totalTasksCount: 3
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ProgressEntry) -> Void) {
        let entry = fetchEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ProgressEntry>) -> Void) {
        let entry = fetchEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func fetchEntry() -> ProgressEntry {
        guard let container = modelContainer else {
            return ProgressEntry(
                date: Date(),
                todayCompletedCount: 0,
                todayTotalCount: 0,
                completedTasksCount: 0,
                totalTasksCount: 0
            )
        }

        let context = ModelContext(container)
        let calendar = Calendar.current

        // 今日完了したステップ数（completedAt != nil のものを取得し、日付でフィルタ）
        let completedStepsDescriptor = FetchDescriptor<SchemaV2.TaskStep>(
            predicate: #Predicate<SchemaV2.TaskStep> { step in
                step.isCompleted && step.completedAt != nil
            }
        )
        let allCompletedSteps = (try? context.fetch(completedStepsDescriptor)) ?? []
        let todayCompletedSteps = allCompletedSteps.filter { step in
            guard let completedAt = step.completedAt else { return false }
            return calendar.isDate(completedAt, inSameDayAs: Date())
        }

        // 全タスク
        let tasksDescriptor = FetchDescriptor<SchemaV2.Task>(
            sortBy: [SortDescriptor(\.order, order: .forward)]
        )
        let tasks = (try? context.fetch(tasksDescriptor)) ?? []

        let totalSteps = tasks.flatMap(\.steps).count
        let completedTasks = tasks.filter { $0.isCompleted }.count

        return ProgressEntry(
            date: Date(),
            todayCompletedCount: todayCompletedSteps.count,
            todayTotalCount: totalSteps,
            completedTasksCount: completedTasks,
            totalTasksCount: tasks.count
        )
    }
}

// MARK: - Widget View

struct ProgressSummaryWidgetView: View {
    let entry: ProgressEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("今日の進捗")
                .font(.caption)
                .foregroundColor(.secondary)

            if entry.todayTotalCount > 0 {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(entry.todayCompletedCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("/ \(entry.todayTotalCount)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                ProgressView(value: Double(entry.todayCompletedCount), total: Double(entry.todayTotalCount))
                    .tint(.green)
            }
            else {
                Text("ステップがありません")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Definition

struct ProgressSummaryWidget: Widget {
    let kind: String = "ProgressSummaryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProgressTimelineProvider()) { entry in
            ProgressSummaryWidgetView(entry: entry)
        }
        .configurationDisplayName("進捗サマリー")
        .description("今日の完了ステップ数を表示します")
        .supportedFamilies([.systemSmall])
    }
}


// MARK: - Widget Bundle

@main
struct BabyStepsWidgetBundle: WidgetBundle {
    var body: some Widget {
        ProgressSummaryWidget()
    }
}
