import SwiftUI

struct ActivityView: View {
    @State private var viewModel: ActivityViewModel
    
    init(modelContext: ModelContext) {
        self._viewModel = State(initialValue: ActivityViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // ヘッダー（月名表示）
                monthHeaderView
                
                // カレンダーグリッド
                CalendarGridView(activities: viewModel.dailyActivities)
                
                // ローディング表示
                if viewModel.isLoading {
                    ProgressView("アクティビティを読み込み中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // エラー表示
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("アクティビティ")
            .onAppear {
                viewModel.loadDailyActivities()
            }
        }
    }
    
    // MARK: - Month Header View
    
    private var monthHeaderView: some View {
        HStack {
            ForEach(getMonthLabels(), id: \.self) { monthLabel in
                Text(monthLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }
    
    // 過去3ヶ月分の月名を取得
    private func getMonthLabels() -> [String] {
        let calendar = Calendar.current
        let now = Date()
        var months: [String] = []
        
        for i in 0..<3 {
            if let date = calendar.date(byAdding: .month, value: -i, to: now) {
                let formatter = DateFormatter()
                formatter.dateFormat = "M月"
                months.insert(formatter.string(from: date), at: 0)
            }
        }
        
        return months
    }
}
