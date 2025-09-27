import SwiftUI

struct DayDetailView: View {
    let activity: DailyActivity
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()
                
                VStack(spacing: 24) {
                    // 日付表示
                    dateHeaderView

                    // アクティビティサマリー
                    activitySummaryView

                    // 完了ステップ一覧（実装予定）
                    completedStepsView

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                    .liquidGlass(intensity: 0.1, cornerRadius: 8)
                }
            }
        }
    }

    // MARK: - Date Header View

    private var dateHeaderView: some View {
        LiquidGlassCard(intensity: 0.1, cornerRadius: 16, padding: 20) {
            VStack(spacing: 8) {
                Text(formatDate(activity.date))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(formatWeekday(activity.date))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Activity Summary View

    private var activitySummaryView: some View {
        LiquidGlassCard(intensity: 0.12, cornerRadius: 16, padding: 20) {
            VStack(spacing: 16) {
                HStack {
                    Text("アクティビティレベル")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(activityLevelText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("完了したステップ")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(activity.commitCount)件")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // アクティビティレベルインジケーター
                HStack(spacing: 6) {
                    ForEach(ActivityLevel.allCases, id: \.self) { level in
                        Circle()
                            .fill(level == activity.activityLevel ? level.color : Color.gray.opacity(0.3))
                            .frame(width: 14, height: 14)
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
        }
    }

    // MARK: - Completed Steps View

    private var completedStepsView: some View {
        LiquidGlassCard(intensity: 0.1, cornerRadius: 16, padding: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("完了したステップ")
                    .font(.headline)
                    .foregroundColor(.primary)

                if activity.commitCount > 0 {
                    Text("完了したステップ: \(activity.commitCount)件")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                else {
                    Text("この日は完了したステップがありません")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Helper Methods

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: date)
    }

    private func formatWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    private var activityLevelText: String {
        switch activity.activityLevel {
        case .none: return "なし"
        case .low: return "低"
        case .medium: return "中"
        case .high: return "高"
        case .veryHigh: return "最高"
        }
    }
}
