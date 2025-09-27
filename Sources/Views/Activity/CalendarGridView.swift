import SwiftUI

struct CalendarGridView: View {
    let activities: [DailyActivity]

    /// 日曜日〜土曜日
    private let columns = 7
    /// 約90日分
    private let rows = 13

    var body: some View {
        LiquidGlassCard(intensity: 0.08, cornerRadius: 20, padding: 20) {
            VStack(spacing: 12) {
                Text("アクティビティカレンダー")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                // カレンダーグリッド
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: columns), spacing: 6) {
                    ForEach(0..<rows, id: \.self) { row in
                        ForEach(0..<columns, id: \.self) { column in
                            let index = row * columns + column
                            if index < activities.count {
                                ActivityCell(activity: activities[index])
                            }
                            else {
                                // 空のセル（過去の日付でアクティビティがない場合）
                                Color.clear
                                    .frame(height: 24)
                            }
                        }
                    }
                }
            }
        }
    }

}

// MARK: - Activity Cell

struct ActivityCell: View {
    let activity: DailyActivity
    @State private var showingDetail = false

    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            RoundedRectangle(cornerRadius: 4)
                .fill(activity.activityLevel.color)
                .frame(height: 24)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.3),
                                    .clear,
                                    .white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
                .shadow(
                    color: .black.opacity(0.1),
                    radius: 2,
                    x: 0,
                    y: 1
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(showingDetail ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showingDetail)
        .sheet(isPresented: $showingDetail) {
            DayDetailView(activity: activity)
        }
    }
}
