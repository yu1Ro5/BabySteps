import SwiftData
import SwiftUI
import WidgetKit

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
        if let container = modelContainer {
            let context = ModelContext(container)
            return WidgetDataProvider.fetchProgress(context: context, referenceDate: Date())
        }

        // SwiftData ストアにアクセスできない場合、UserDefaults フォールバックを試す
        // （containerURL が nil でも UserDefaults(suiteName:) は動作することがある）
        if let entry = WidgetDataSync.readFromUserDefaults(referenceDate: Date()) {
            return entry
        }

        return ProgressEntry(
            date: Date(),
            todayCompletedCount: 0,
            todayTotalCount: 0,
            completedTasksCount: 0,
            totalTasksCount: 0
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
