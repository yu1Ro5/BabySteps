# BabySteps ウィジェット機能 設計計画書

アプリを開かなくても使えるウィジェット機能の設計・実装計画です。

---

## 1. 概要

### 1.1 目的

- ホーム画面・ロック画面から**今日の進捗**や**タスク状況**を一目で確認できるようにする
- アプリを起動せずに「今日どれくらい進んだか」を把握できる体験を提供する

### 1.2 技術スタック

| 項目 | 技術 |
| --- | --- |
| フレームワーク | WidgetKit（iOS 標準） |
| データ共有 | App Groups + SwiftData |
| UI | SwiftUI（Widget 用 API） |
| ターゲット | iOS 26.0+（既存アプリと同様） |

---

## 2. アーキテクチャ

### 2.1 構成図

```
┌─────────────────────────────────────────────────────────────────┐
│  App Group Container (group.com.yu1Ro5.BabySteps)                │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  default.store (SwiftData)                                   ││
│  │  - Task, TaskStep モデル                                     ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
         ↑                                    ↑
         │                                    │
┌────────┴────────┐                 ┌────────┴────────┐
│  BabySteps App  │                 │  Widget Extension│
│  (メインアプリ)  │                 │  (別プロセス)     │
│  - 読み書き    │                 │  - 読み取り専用   │
│  - データ更新時 │                 │  - TimelineEntry  │
│  reloadAllTimelines()│            │  - 表示のみ      │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 重要なポイント

1. **App Groups**: メインアプリとウィジェット拡張は**別プロセス**のため、App Group で共有コンテナを指定する
2. **SwiftData ストア位置**: 既存の `Application Support` から **App Group コンテナ**へ移行する必要がある
3. **マイグレーション**: 既存ユーザーのデータ移行を考慮した設計が必須

---

## 3. ウィジェット種別の設計

### 3.1 推奨ウィジェット一覧

| ウィジェット | サイズ | 表示内容 | 用途 |
| --- | --- | --- | --- |
| **進捗サマリー** | Small / Medium | 今日の完了ステップ数、全体進捗率 | ホーム画面の定番 |
| **アクティビティミニ** | Medium / Large | 直近 7〜14 日分のカレンダー風表示 | 習慣の可視化 |
| **次のステップ** | Small | 進行中タスクの先頭 1 件＋次のステップ | やるべきことのリマインド |

### 3.2 各ウィジェットの詳細

#### 3.2.1 進捗サマリー（Progress Summary）

- **Small**: 今日の完了数（例: `今日 5/12`）＋プログレスバー
- **Medium**: 今日の完了数 ＋ 全体進捗（例: `3 タスク中 2 完了`）＋ プログレスバー
- **ロック画面**: インライン（今日の完了数のみ）

**データソース**: `TaskStep.completedAt` が今日の日付の件数、全タスクの `isCompleted` 割合

#### 3.2.2 アクティビティミニ（Activity Mini）

- **Medium**: 直近 7 日分のドット表示（GitHub 風）
- **Large**: 直近 14 日分のドット表示

**データソース**: `ActivityView` と同様の `countStepsByDate` ロジック

#### 3.2.3 次のステップ（Next Step）

- **Small**: 進行中タスクの 1 件目＋「次にやるステップ」の説明（例: タスク名＋「ステップ 3/5」）
- タップでアプリを開く（`widgetURL`）

**データソース**: `fetchInProgressTasks()` の先頭タスク

---

## 4. データ共有の設計

### 4.1 App Group 設定

| 項目 | 値 |
| --- | --- |
| App Group ID | `group.com.yu1Ro5.BabySteps` |
| 対象ターゲット | BabySteps（メイン）、BabyStepsWidget（拡張） |

### 4.2 SwiftData ストアの移行

**現状**:
```swift
// BabyStepsApp.swift
let storeURL = FileManager.default
    .urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    .appendingPathComponent("default.store")
```

**移行後**:
```swift
// App Group コンテナを優先、フォールバックで既存パス
let containerURL = FileManager.default
    .containerURL(forSecurityApplicationGroupIdentifier: "group.com.yu1Ro5.BabySteps")
    ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
let storeURL = containerURL.appendingPathComponent("default.store")
```

**初回起動時のデータ移行**:
- 既存の `Application Support/default.store` が存在する場合、App Group コンテナへコピー
- コピー成功後に旧ストアを削除（オプション: バックアップとして残す）

### 4.3 ウィジェット用のデータ取得

ウィジェットは **TimelineProvider** で `TimelineEntry` を生成する。各 Entry には:

- `date`: 表示タイミング
- `todayCompletedCount`: 今日の完了ステップ数
- `totalProgress`: 全体進捗（完了タスク数 / 全タスク数）
- `dailyActivities`: 日別アクティビティ（アクティビティウィジェット用）
- `nextTask`: 次のステップ情報（次のステップウィジェット用）

これらは SwiftData の `ModelContext` から取得する。ウィジェット用の `ModelContainer` は App Group URL を指定して初期化する。

---

## 5. タイムライン更新戦略

### 5.1 更新頻度

| トリガー | 動作 |
| --- | --- |
| アプリでデータ変更 | `WidgetCenter.shared.reloadAllTimelines()` を呼ぶ |
| システムによる更新 | WidgetKit が適宜スケジュール（1 日数回程度） |
| 深夜 0 時 | 今日のカウントがリセットされるため、0:00 付近の Entry を用意 |

### 5.2 実装箇所

`TaskViewModel` の以下のメソッド内で `reloadAllTimelines()` を呼ぶ:

- `toggleStepCompletion`
- `createTaskWithSteps`
- `deleteTask`
- `addStep` / `removeStep`
- `updateTaskTitle`
- `moveTasks`

---

## 6. プロジェクト構成

### 6.1 追加ファイル

```
Sources/
├── Widget/
│   ├── BabyStepsWidget.swift      # Widget 拡張エントリ
│   ├── ProgressSummaryWidget.swift # 進捗サマリー
│   ├── ActivityMiniWidget.swift   # アクティビティミニ
│   └── NextStepWidget.swift       # 次のステップ（オプション）
```

または、1 つの Widget 拡張内で複数ウィジェット種別を `@Widget` で定義する構成も可能。

### 6.2 project.yml の変更

- `BabySteps` ターゲット: App Groups  capability 追加
- 新規ターゲット `BabyStepsWidget`: Widget Extension、App Groups、SwiftData モデルを共有
- `Sources/Models/` の Swift ファイルを Widget ターゲットにも含める

---

## 7. 実装フェーズ

### Phase 1: 基盤（1〜2 日）

1. **App Group の設定**
   - Xcode / project.yml で App Group を追加
   - メインアプリの SwiftData ストアを App Group コンテナへ移行
   - 既存データの移行ロジック（初回のみ）

2. **Widget Extension の追加**
   - 新規ターゲット `BabyStepsWidget` 作成
   - 最小限の「進捗サマリー」ウィジェット（Small）を実装
   - SwiftData から今日の完了数・全体進捗を取得

### Phase 2: ウィジェット拡張（1〜2 日）

3. **進捗サマリーの完成**
   - Medium サイズ対応
   - ロック画面ウィジェット対応（iOS 16+）

4. **データ変更時のリロード**
   - `TaskViewModel` に `WidgetCenter.reloadAllTimelines()` を組み込み

### Phase 3: 追加ウィジェット（オプション、1 日）

5. **アクティビティミニ**
   - 直近 7 日分のドット表示

6. **次のステップ**
   - 進行中タスクの表示

---

## 8. 注意事項・リスク

### 8.1 データ移行

- 既存ユーザーが `Application Support` にデータを持っている場合、App Group 移行時に**データ消失**のリスクがある
- 移行前にコピーし、成功を確認してから旧ストアを削除する方針を推奨

### 8.2 ウィジェットの制約

- ウィジェットは**読み取り専用**。タップでアプリを開くのみ
- バッテリー・リソースの制約により、システムが更新頻度を制限する場合がある
- 複雑な UI や大量データの表示は避ける

### 8.3 テスト

- シミュレータでウィジェットの表示を確認
- App Group が有効な状態で、メインアプリとウィジェットが同一データを参照することを確認
- データ移行のテスト（既存ストアあり → App Group 移行）

---

## 9. 次のステップ

1. この設計計画のレビュー・承認
2. Phase 1 の実装開始（App Group 設定、ストア移行、最小ウィジェット）
3. 動作確認後、Phase 2 へ進行

---

## 参考リンク

- [WidgetKit - Apple Developer](https://developer.apple.com/documentation/widgetkit)
- [App Groups - Apple Developer](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups)
- [Access SwiftData in Widgets - Apple Developer Forums](https://developer.apple.com/forums/thread/756788)
- [How to access a SwiftData container from widgets - Hacking with Swift](https://www.hackingwithswift.com/quick-start/swiftdata/how-to-access-a-swiftdata-container-from-widgets)
