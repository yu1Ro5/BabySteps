import SwiftUI

struct DayDetailView: View {
    let activity: DailyActivity
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 日付表示
                dateHeaderView
                
                // アクティビティサマリー
                activitySummaryView
                
                // 完了ステップ一覧（実装予定）
                completedStepsView
                
                Spacer()
            }
            .padding()
            .navigationTitle("詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Date Header View
    
    private var dateHeaderView: some View {
        VStack(spacing: 8) {
            Text(formatDate(activity.date))
                .font(.title2)
                .fontWeight(.bold)
            
            Text(formatWeekday(activity.date))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Activity Summary View
    
    private var activitySummaryView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("アクティビティレベル")
                    .font(.headline)
                Spacer()
                Text(activityLevelText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("完了したステップ")
                    .font(.headline)
                Spacer()
                Text("\(activity.commitCount)件")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // アクティビティレベルインジケーター
            HStack(spacing: 4) {
                ForEach(ActivityLevel.allCases, id: \.self) { level in
                    Circle()
                        .fill(level == activity.activityLevel ? level.color : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Completed Steps View
    
    private var completedStepsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("完了したステップ")
                .font(.headline)
            
            if activity.commitCount > 0 {
                Text("完了したステップ: \(activity.commitCount)件")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("この日は完了したステップがありません")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
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
