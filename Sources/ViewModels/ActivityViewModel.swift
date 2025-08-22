import Foundation
import SwiftData

@Observable
class ActivityViewModel {
    private let modelContext: ModelContext
    
    // Viewの状態
    var dailyActivities: [DailyActivity] = []
    var isLoading = false
    var errorMessage: String?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        // 初期データ読み込み
        loadDailyActivities()
    }
    
    // MARK: - Public Methods
    
    // 日別アクティビティを読み込み
    func loadDailyActivities(for days: Int = 90) {
        isLoading = true
        errorMessage = nil
        
        do {
            dailyActivities = try getDailyActivities(for: days)
        } catch {
            errorMessage = "アクティビティの読み込みに失敗しました: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // アクティビティを強制更新（外部から呼び出し可能）
    func refreshActivities() {
        loadDailyActivities()
    }
    
    // MARK: - Private Methods
    
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
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<TaskStep> { step in
            step.isCompleted && 
            step.completedAt != nil &&
            step.completedAt! >= startOfDay &&
            step.completedAt! < endOfDay
        }
        
        let descriptor = FetchDescriptor<TaskStep>(predicate: predicate)
        
        do {
            return try modelContext.fetch(descriptor).count
        } catch {
            print("ステップ取得エラー: \(error)")
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
