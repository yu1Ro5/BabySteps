# BabySteps アプリ データベース設計書

## 1. 概要

### 1.1 使用技術
- **データベース**: SwiftData
- **プラットフォーム**: iOS 18.0+
- **アーキテクチャ**: MVVM + SwiftData

### 1.2 設計方針
- ローカル完結のデータ管理
- シンプルで拡張しやすい構造
- パフォーマンスを重視した設計

## 2. エンティティ設計

### 2.1 Task（タスク）

**Task（タスク）**
- 基本情報：ID、名前、説明、カテゴリ、優先度、目標着手回数
- 状態管理：完了状態、アーカイブ状態
- 日時情報：作成日時、更新日時、完了日時
- 統計情報：総着手回数、最終着手日時
- リレーション：着手記録（cascade削除）
```

### 2.2 Attempt（着手記録）

**Attempt（着手記録）**
- 基本情報：ID、着手日時、メモ
- リレーション：タスク（親）
```

### 2.3 TaskCategory（タスクカテゴリ）

**TaskCategory（タスクカテゴリ）**
- 習慣、プロジェクト、学習、その他
- 各カテゴリに表示名、アイコン、色を定義
```

### 2.4 Priority（優先度）

**Priority（優先度）**
- 低、中、高の3段階
- 各優先度に表示名、アイコン、色を定義
```

## 3. データベーススキーマ

### 3.1 スキーマ定義

**BabyStepsSchema**
- Task、Attemptの2つのエンティティを定義
- ModelContainerの設定（永続化、エラーハンドリング）
```

### 3.2 マイグレーション対応

**マイグレーション対応**
- SchemaV1: 基本エンティティ（Task、Attempt）
- SchemaV2: アーカイブ機能、タグ機能の追加
```

## 4. データアクセス層

### 4.1 TaskRepository

**TaskRepository**
- タスクのCRUD操作
- アクティブタスク、完了タスク、カテゴリ別タスクの取得
- タスクの完了、アーカイブ、削除処理
```

### 4.2 AttemptRepository

```swift
class AttemptRepository: ObservableObject {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - 着手記録作成
    func recordAttempt(for task: Task, note: String? = nil) throws -> Attempt {
        let attempt = Attempt(task: task, note: note)
        modelContext.insert(attempt)
        
        // タスクの統計情報を更新
        task.totalAttempts += 1
        task.lastAttemptAt = Date()
        task.updatedAt = Date()
        
        try modelContext.save()
        return attempt
    }
    
    // MARK: - 着手記録取得
    func fetchAttempts(for task: Task, limit: Int = 10) throws -> [Attempt] {
        let descriptor = FetchDescriptor<Attempt>(
            predicate: #Predicate<Attempt> { attempt in
                attempt.task?.id == task.id
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor)
    }
    
    func fetchAttemptsInDateRange(from: Date, to: Date) throws -> [Attempt] {
        let descriptor = FetchDescriptor<Attempt>(
            predicate: #Predicate<Attempt> { attempt in
                attempt.timestamp >= from && attempt.timestamp <= to
            },
            sortBy: [SortDescriptor(\.timestamp, order: .descending)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    // MARK: - 統計情報取得
    func getTotalAttempts(for task: Task) -> Int {
        return task.totalAttempts
    }
    
    func getAttemptsToday() throws -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let attempts = try fetchAttemptsInDateRange(from: today, to: tomorrow)
        return attempts.count
    }
    
    func getStreakDays(for task: Task) throws -> Int {
        let attempts = try fetchAttempts(for: task, limit: 100)
        var streak = 0
        var currentDate = Date()
        
        for attempt in attempts {
            let attemptDate = Calendar.current.startOfDay(for: attempt.timestamp)
            let currentDateStart = Calendar.current.startOfDay(for: currentDate)
            
            if Calendar.current.isDate(attemptDate, inSameDayAs: currentDateStart) {
                streak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }
        
        return streak
    }
}
```

## 5. データ整合性

### 5.1 制約事項
- タスク名は必須（空文字列不可）
- 着手回数は0以上の整数
- 完了日時は完了状態の時のみ設定可能
- 削除されたタスクに関連する着手記録も削除

### 5.2 バリデーション
- タスク名の空文字チェック
- 着手回数の非負整数チェック
- 完了・アーカイブ状態の整合性チェック

## 6. パフォーマンス最適化

### 6.1 インデックス設定
- 検索頻度の高いフィールドにインデックスを設定
- カテゴリ、完了状態、作成日時、着手日時

### 6.2 クエリ最適化
- 必要なフィールドのみを取得
- 適切なfetchLimitの設定
- 複雑なクエリの回避

## 7. バックアップ・復元

### 7.1 データエクスポート
- CSV形式でのデータ出力
- JSON形式でのデータ出力

### 7.2 データインポート
- JSON形式からのデータインポート
- インポートデータの検証

## 8. 将来の拡張性

### 8.1 iCloud同期対応
- CloudKitとの連携
- 競合解決の仕組み
- オフライン対応

### 8.2 通知機能
- ローカル通知の管理
- 通知履歴の保存

### 8.3 データ分析
- 高度な統計計算
- 機械学習による予測
- パフォーマンス分析
