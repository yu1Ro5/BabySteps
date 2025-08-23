# Activity アクティビティタブ仕様書

## 📋 概要

Activityタブは、BabyStepsアプリでユーザーの日々の活動を可視化する画面です。GitHubのcontribution graphのような形式で、過去90日間のタスク完了状況をカレンダー形式で表示し、ユーザーの継続的な努力を視覚的に確認できるよう設計されています。

## 🏗️ アーキテクチャ

### MVVM (Model-View-ViewModel) パターン

- **View**: `ActivityView.swift` - メイン画面とナビゲーション
- **ViewModel**: `ActivityViewModel.swift` - アクティビティデータの計算と管理
- **Model**: `DailyActivity.swift`, `ActivityLevel.swift` - アクティビティデータ構造
- **Sub Views**: `CalendarGridView.swift`, `DayDetailView.swift` - カレンダー表示と詳細表示

### 依存関係

```
ActivityView → ActivityViewModel → DailyActivity/ActivityLevel
                ↓
            TaskViewModel (タスク完了通知)
                ↓
            SwiftData (TaskStep完了データ)
```

## 📱 UI構成

### 1. ヘッダー部分
- **ナビゲーションバー**: "アクティビティ" タイトル
- **月名表示**: 過去3ヶ月分の月名を横並びで表示

### 2. カレンダーグリッド
- **曜日ヘッダー**: 日曜日〜土曜日の曜日表示
- **日付セル**: 過去90日分の日付を7列×13行のグリッドで表示
- **アクティビティレベル**: 各日の完了ステップ数に応じた色分け表示

### 3. 詳細表示
- **日付詳細**: タップした日の詳細情報をモーダル表示
- **アクティビティサマリー**: 完了ステップ数とアクティビティレベル
- **レベルインジケーター**: 全レベルの視覚的比較

## 🔧 主要機能

### アクティビティ表示
- **カレンダー形式**: GitHub風のcontribution graph
- **過去90日分**: 十分な履歴データの表示
- **リアルタイム更新**: タスク完了時の即座反映

### アクティビティレベル
- **5段階評価**: なし、低、中、高、最高
- **色分け表示**: 各レベルに応じた色の使用
- **視覚的フィードバック**: 一目で活動量を把握

### 詳細情報
- **日付表示**: 年月日と曜日の表示
- **ステップ数**: その日に完了したステップ数
- **レベル説明**: アクティビティレベルのテキスト説明

## 📊 データモデル

### DailyActivity 構造体
```swift
struct DailyActivity {
    let date: Date           // 対象日
    let commitCount: Int     // 完了ステップ数
    let activityLevel: ActivityLevel  // アクティビティレベル
}
```

### ActivityLevel 列挙型
```swift
enum ActivityLevel: Int, CaseIterable {
    case none = 0      // 0件
    case low = 1       // 1-3件
    case medium = 2    // 4-6件
    case high = 3      // 7-9件
    case veryHigh = 4  // 10件以上
}
```

### カラー定義
```swift
var color: Color {
    switch self {
    case .none: return Color(hex: "#ebedf0")      // グレー
    case .low: return Color(hex: "#a8e6b8")      // 薄い緑
    case .medium: return Color(hex: "#4cd46e")    // 明るい緑
    case .high: return Color(hex: "#3bb85a")     // 緑
    case .veryHigh: return Color(hex: "#2a8a47")  // 濃い緑
    }
}
```

## 🔄 データフロー

### 1. 初期化フロー
```
アプリ起動 → ActivityViewModel初期化 → 過去90日分データ計算 → UI表示
```

### 2. データ計算フロー
```
日付範囲設定 → 各日の完了ステップ数取得 → アクティビティレベル計算 → DailyActivity生成
```

### 3. 更新フロー
```
タスク完了 → 通知受信 → アクティビティ再計算 → UI更新
```

### 4. 詳細表示フロー
```
日付セルタップ → 詳細データ取得 → モーダル表示
```

## 🎯 ビジネスロジック

### アクティビティレベル計算
```swift
private func calculateActivityLevel(_ commitCount: Int) -> ActivityLevel {
    switch commitCount {
    case 0: return .none
    case 1...3: return .low
    case 4...6: return .medium
    case 7...9: return .high
    default: return .veryHigh
    }
}
```

### 日付範囲計算
```swift
private func getDailyActivities(for days: Int) throws -> [DailyActivity] {
    let calendar = Calendar.current
    let endDate = Date()  // 当日を含む
    let startDate = calendar.date(byAdding: .day, value: -days, to: endDate)!
    
    var activities: [DailyActivity] = []
    var currentDate = startDate
    
    while currentDate <= endDate {  // 当日まで含む
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
```

### 完了ステップ数取得
```swift
private func getCommitCount(for date: Date) -> Int {
    let calendar = Calendar.current
    
    // 指定された日の開始時刻（00:00:00）
    let startOfDay = calendar.startOfDay(for: date)
    
    // 指定された日の終了時刻（23:59:59.999）
    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
    
    let predicate = #Predicate<TaskStep> { step in
        step.isCompleted && 
        step.completedAt != nil &&
        step.completedAt! >= startOfDay &&
        step.completedAt! < endOfDay
    }
    
    let descriptor = FetchDescriptor<TaskStep>(predicate: predicate)
    
    do {
        let completedSteps = try modelContext.fetch(descriptor)
        return completedSteps.count
    } catch {
        return 0
    }
}
```

## 🔗 連携機能

### TaskViewModel連携
- **通知メカニズム**: `onActivityUpdate` コールバック
- **更新タイミング**: タスク/ステップの状態変更時
- **データ同期**: 完了ステップ数の自動再計算

### SwiftData連携
- **データ取得**: TaskStepエンティティからの完了データ取得
- **フィルタリング**: 完了済みかつ特定日付のステップを抽出
- **リアルタイム更新**: データベース変更の自動検知

## 📱 ユーザーインタラクション

### タッチ操作
- **タップ**: 日付セルの詳細表示
- **スクロール**: カレンダーの表示範囲調整（将来的な機能）

### 視覚的フィードバック
- **色分け**: アクティビティレベルに応じた色表示
- **境界線**: セルの境界線表示
- **ホバー効果**: タップ可能な要素の視覚的表現

## 🎨 UI/UX設計

### デザイン原則
- **GitHub風**: 一般的なcontribution graphのデザイン
- **直感的**: 色の濃さで活動量を直感的に理解
- **一貫性**: 全体的なデザインシステムとの統一

### レイアウト設計
- **グリッドレイアウト**: 7列×13行の固定グリッド
- **レスポンシブ**: 画面サイズに応じた適応
- **スペーシング**: 適切な要素間の余白

### アクセシビリティ
- **VoiceOver対応**: 各セルの適切な説明
- **色覚対応**: 色だけでなく形でも情報を表現
- **コントラスト**: 十分な色のコントラスト比

## 🚀 パフォーマンス

### 最適化戦略
- **効率的な計算**: 必要時のみデータベースクエリ実行
- **キャッシュ**: 計算済みデータの再利用
- **遅延読み込み**: 表示時に必要なデータのみ取得

### 制限事項
- **表示日数**: 最大90日分
- **更新頻度**: タスク完了時のみ
- **データサイズ**: SwiftDataの制限に依存

## 📊 データ表示ロジック

### カレンダーグリッド
```swift
private let columns = 7 // 日曜日〜土曜日
private let rows = 13   // 約90日分

LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: columns), spacing: 4) {
    ForEach(0..<rows, id: \.self) { row in
        ForEach(0..<columns, id: \.self) { column in
            let index = row * columns + column
            if index < activities.count {
                ActivityCell(activity: activities[index])
            } else {
                Color.clear.frame(height: 20)
            }
        }
    }
}
```

### 月名表示
```swift
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
```

## 🔮 将来の拡張

### 計画中の機能
- **期間選択**: 表示期間のカスタマイズ
- **フィルタリング**: 特定のタスク/カテゴリでの絞り込み
- **統計情報**: 週間/月間の統計表示
- **エクスポート**: アクティビティデータの外部出力

### 技術的改善
- **アニメーション**: データ更新時のスムーズな表示
- **オフライン対応**: ネットワーク不要での動作
- **データ同期**: 複数デバイス間での同期

## 📝 開発者向け情報

### ファイル構成
```
Sources/
├── Views/Activity/
│   ├── ActivityView.swift        # メイン画面
│   ├── CalendarGridView.swift    # カレンダーグリッド
│   └── DayDetailView.swift      # 日付詳細表示
├── ViewModels/
│   └── ActivityViewModel.swift   # アクティビティロジック
└── Models/
    ├── Activity.swift            # アクティビティデータ
    └── ActivityLevel.swift       # アクティビティレベル
```

### テスト戦略
- **Unit Tests**: ViewModel、Modelのロジック
- **UI Tests**: カレンダー表示と詳細表示
- **Integration Tests**: SwiftData連携とデータ計算

### デバッグ情報
- **ログ出力**: データ計算過程の詳細ログ
- **エラーハンドリング**: データ取得失敗時の適切な処理
- **状態監視**: アクティビティデータの状態変化追跡

### パフォーマンス監視
- **計算時間**: アクティビティ計算の実行時間
- **メモリ使用量**: データ保持時のメモリ消費
- **データベースクエリ**: クエリの実行頻度と効率性