import SwiftUI

struct CalendarGridView: View {
    let activities: [DailyActivity]
    
    /// 日曜日〜土曜日
    private let columns = 7
    /// 約90日分
    private let rows = 13

    var body: some View {
        VStack(spacing: 8) {
            // カレンダーグリッド
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: columns), spacing: 4) {
                ForEach(0..<rows, id: \.self) { row in
                    ForEach(0..<columns, id: \.self) { column in
                        let index = row * columns + column
                        if index < activities.count {
                            ActivityCell(activity: activities[index])
                        } else {
                            // 空のセル（過去の日付でアクティビティがない場合）
                            Color.clear
                                .frame(height: 20)
                        }
                    }
                }
            }
            .padding(.horizontal)
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
            RoundedRectangle(cornerRadius: 2)
                .fill(activity.activityLevel.color)
                .frame(height: 20)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            DayDetailView(activity: activity)
        }
    }
}
