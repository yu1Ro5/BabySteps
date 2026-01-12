import Foundation

struct DailyActivity: Identifiable {
    var id: Date { date }
    let date: Date
    let commitCount: Int
    let activityLevel: ActivityLevel
}
