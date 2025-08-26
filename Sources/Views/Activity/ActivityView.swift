import SwiftUI
import SwiftData

struct ActivityView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var completedSteps: [TaskStep]
    @State private var dailyActivities: [DailyActivity] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
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
    
    // 日別アクティビティを読み込み
    private func loadDailyActivities(for days: Int = 90) {
        print("📊 アクティビティ読み込み開始 (過去\(days)日分)")
        isLoading = true
        errorMessage = nil
        
        do {
            dailyActivities = try getDailyActivities(for: days)
            print("📊 アクティビティ読み込み完了: \(dailyActivities.count)日分")
        } catch {
            errorMessage = "アクティビティの読み込みに失敗しました: \(error.localizedDescription)"
            print("❌ アクティビティ読み込みエラー: \(error)")
        }
        
        isLoading = false
    }
    
    // 指定された日数分の日別アクティビティを取得
    private func getDailyActivities(for days: Int) throws -> [DailyActivity] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: endDate)!
        
        var activities: [DailyActivity] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let commitCount = getCommitCount(for: currentDate)
            let level = calculateActivityLevel(commitCount)
            
            activities.append(DailyActivity(
                date: currentDate,
                commitCount: commitCount,
                activityLevel: level
            ))
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return activities
    }
    
    // 指定された日のステップ完了数を取得
    private func getCommitCount(for date: Date) -> Int {
        let calendar = Calendar.current
        
        // 指定された日の開始時刻（00:00:00）
        let startOfDay = calendar.startOfDay(for: date)
        
        // 指定された日の終了時刻（23:59:59.999）
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // デバッグ用：日付範囲をログ出力
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        
        print("🔍 検索対象日: \(dateFormatter.string(from: date))")
        print("🔍 開始時刻: \(dateFormatter.string(from: startOfDay))")
        print("🔍 終了時刻: \(dateFormatter.string(from: endOfDay))")
        
        // より安全な日付範囲計算
        let startOfDayComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let endOfDayComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        guard let startOfDaySafe = calendar.date(from: startOfDayComponents),
              let endOfDaySafe = calendar.date(byAdding: .day, value: 1, to: startOfDaySafe) else {
            print("❌ 日付計算エラー")
            return 0
        }
        
        print("🔍 安全な開始時刻: \(dateFormatter.string(from: startOfDaySafe))")
        print("🔍 安全な終了時刻: \(dateFormatter.string(from: endOfDaySafe))")
        
        let predicate = #Predicate<TaskStep> { step in
            step.isCompleted && 
            step.completedAt != nil &&
            step.completedAt! >= startOfDaySafe &&
            step.completedAt! < endOfDaySafe
        }
        
        let descriptor = FetchDescriptor<TaskStep>(predicate: predicate)
        
        do {
            let completedSteps = try modelContext.fetch(descriptor)
            
            // デバッグ用：完了済みステップの詳細をログ出力
            print("🔍 完了済みステップ数: \(completedSteps.count)")
            for step in completedSteps {
                if let completedAt = step.completedAt {
                    print("  - ステップ\(step.order + 1), 完了時刻: \(dateFormatter.string(from: completedAt))")
                }
            }
            
            return completedSteps.count
        } catch {
            print("❌ ステップ取得エラー: \(error)")
            return 0
        }
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
