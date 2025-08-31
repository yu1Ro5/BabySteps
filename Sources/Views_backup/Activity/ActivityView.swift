import SwiftUI
import SwiftData

struct ActivityView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var completedSteps: [TaskStep]
    @State private var dailyActivities: [DailyActivity] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var lastCalculationDate: Date?
    @State private var calculationCache: [Date: DailyActivity] = [:]
    @State private var lastStepsHash: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // カレンダーグリッド
                if !dailyActivities.isEmpty {
                    CalendarGridView(activities: dailyActivities)
                }
                
                // ローディング表示
                if isLoading {
                    ProgressView("アクティビティを読み込み中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // エラー表示
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("アクティビティ")
            .onAppear {
                // 初期データ読み込み
                loadDailyActivities()
            }
            .onChange(of: completedSteps) { _, newSteps in
                // ステップの変更を検知してアクティビティを更新
                print("🔄 ステップ変更を検知: \(newSteps.count)件")
                loadDailyActivities()
            }
        }
    }
    
    // MARK: - Private Methods
    
    // 日別アクティビティを読み込み（最適化版）
    private func loadDailyActivities(for days: Int = 90) {
        let today = Date()
        
        // ステップの内容が変更されたかチェック
        let currentStepsHash = calculateStepsHash(completedSteps)
        let stepsChanged = currentStepsHash != lastStepsHash
        
        // 今日のデータが既に計算済みで、ステップに変更がない場合
        if let lastCalc = lastCalculationDate,
           Calendar.current.isDate(lastCalc, inSameDayAs: today) && !stepsChanged {
            print("📊 今日のデータは既に計算済み、キャッシュを使用")
            return
        }
        
        print("📊 アクティビティ読み込み開始 (過去\(days)日分)")
        isLoading = true
        errorMessage = nil
        
        do {
            dailyActivities = try getDailyActivities(for: days)
            lastCalculationDate = today
            lastStepsHash = currentStepsHash
            print("📊 アクティビティ読み込み完了: \(dailyActivities.count)日分")
        } catch {
            errorMessage = "アクティビティの読み込みに失敗しました: \(error.localizedDescription)"
            print("❌ アクティビティ読み込みエラー: \(error)")
        }
        
        isLoading = false
    }
    
    // ステップの内容をハッシュ化して変更検知
    private func calculateStepsHash(_ steps: [TaskStep]) -> Int {
        var hasher = Hasher()
        for step in steps {
            hasher.combine(step.id)
            hasher.combine(step.isCompleted)
            if let completedAt = step.completedAt {
                hasher.combine(completedAt.timeIntervalSince1970)
            }
        }
        return hasher.finalize()
    }
    
    // 指定された日数分の日別アクティビティを取得（最適化版）
    private func getDailyActivities(for days: Int) throws -> [DailyActivity] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: endDate)!
        
        // 完了済みステップを日付別にグループ化
        let stepsByDate = groupStepsByDate(completedSteps)
        
        var activities: [DailyActivity] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let dateKey = calendar.startOfDay(for: currentDate)
            let commitCount = stepsByDate[dateKey]?.count ?? 0
            let level = calculateActivityLevel(commitCount)
            
            let activity = DailyActivity(
                date: currentDate,
                commitCount: commitCount,
                activityLevel: level
            )
            
            activities.append(activity)
            
            // キャッシュに保存
            calculationCache[dateKey] = activity
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return activities
    }
    
    // ステップを日付別にグループ化（効率化）
    private func groupStepsByDate(_ steps: [TaskStep]) -> [Date: [TaskStep]] {
        let calendar = Calendar.current
        var groupedSteps: [Date: [TaskStep]] = [:]
        
        for step in steps {
            guard let completedAt = step.completedAt else { continue }
            let dateKey = calendar.startOfDay(for: completedAt)
            
            if groupedSteps[dateKey] == nil {
                groupedSteps[dateKey] = []
            }
            groupedSteps[dateKey]?.append(step)
        }
        
        return groupedSteps
    }
    
    // 指定された日のステップ完了数を取得（非推奨 - 効率化版に置き換え）
    private func getCommitCount(for date: Date) -> Int {
        // このメソッドは非推奨になりました
        // 代わりにgroupStepsByDateを使用してください
        return 0
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
