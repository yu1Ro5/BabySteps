# タスクフィルター機能 実装計画

## 0. 設計方針（標準コンポーネント優先）

独自UIを避け、SwiftUI の標準コンポーネントを利用する。

| 機能 | 使用する標準コンポーネント |
| --- | --- |
| フィルター | `Picker`（`.pickerStyle(.menu)` または `.segmented`） |
| 空状態 | `ContentUnavailableView`（iOS 17+） |

---

## 1. 概要

タスク一覧画面にフィルター機能を追加し、ユーザーがタスクを効率的に絞り込めるようにする。

---

## 2. 機能仕様

### 2.1 フィルター

| フィルター | 条件 | 説明 |
| --- | --- | --- |
| **すべて** | 全タスク | デフォルト |
| **進行中** | ステップが1つ以上あり、かつ未完了のステップが1つ以上ある | 着手済みで未完了 |
| **完了** | ステップが1つ以上あり、かつ全ステップが完了 | 全てのステップ完了 |
| **未着手**（オプション） | ステップが0個 | ステップ未追加 |

**補足**: ステップ0個のタスクは「未着手」として扱う。Phase 1では「すべて」「進行中」「完了」の3つで実装し、必要に応じて「未着手」を追加する。

---

## 3. 技術方針

### 3.1 データフロー

```text
@Query(tasks) → 全タスク取得
       ↓
[View層でフィルタ]
  - フィルター: ステータスに応じて tasks を絞り込み
       ↓
filteredTasks → List に表示
```

**理由**: `@Query` は全件取得のままにし、フィルターは View 層で行う。

- タスク数は通常そこまで多くない想定
- 実装がシンプルでテストしやすい

### 3.2 状態管理

| 状態 | 型 | 保持場所 |
| --- | --- | --- |
| フィルター種別 | `TaskFilter` enum | `MainView` の `@State`（`TaskListView` に Binding で渡す） |

---

## 4. 実装タスク

### Phase 1: コア実装

#### 4.1 モデル・型定義

**ファイル**: `Sources/Models/TaskFilter.swift`

```swift
/// タスク一覧のフィルター種別
enum TaskFilter: String, CaseIterable {
    case all = "すべて"
    case inProgress = "進行中"
    case completed = "完了"
}
```

- `Task` に `isCompleted` 相当の computed property を追加するか、View 側で判定する
- 判定ロジックは ViewModel に集約するのが望ましい（テスト容易性）

#### 4.2 ViewModel 拡張

**ファイル**: `Sources/ViewModels/TaskViewModel.swift`

追加するメソッド（または `Task` モデルに computed property を追加）:

```swift
/// タスクが「完了」かどうか（ステップが1つ以上かつ全完了）
func isTaskCompleted(_ task: Task) -> Bool

/// タスクが「進行中」かどうか（ステップありかつ未完了あり）
func isTaskInProgress(_ task: Task) -> Bool

/// タスクが「未着手」かどうか（ステップ0個）
func isTaskNotStarted(_ task: Task) -> Bool
```

**推奨**: モデルに `isCompleted` を追加し、ViewModel のフィルター用メソッドは `[Task]` をフィルタするユーティリティとして実装。

#### 4.3 View 修正

**ファイル**: `Sources/Views/TaskListView.swift`

1. **状態**
   - `@Binding var selectedFilter: TaskFilter`（MainView から受け取る）

2. **フィルタ済みタスクの計算**
   - `private var filteredTasks: [Task]`（computed property）
   - フィルター: `selectedFilter` に応じて `tasks` を絞り込み

3. **UI**
   - フィルター: ボトムバー左下に `Menu` + `Picker`（`line.3.horizontal.decrease.circle` アイコン）

4. **List のデータソース**
   - `ForEach(filteredTasks, ...)`
   - `onDelete` では `filteredTasks[offset]` を削除対象にする

---

### Phase 2: UI 調整・アクセシビリティ

#### 4.4 フィルターピッカー

- ボトムバー左下に `Menu` で `Picker(selection: $selectedFilter, ...)` を配置
- アイコン: `line.3.horizontal.decrease.circle`

#### 4.5 空状態

- `ContentUnavailableView`（iOS 17+ 標準）を使用
- 例: `ContentUnavailableView("該当するタスクがありません", systemImage: "magnifyingglass", description: Text("フィルターを変えてみてください"))`

---

### Phase 3: テスト

#### 4.6 ユニットテスト

- `Task.isCompleted` のテスト（ステップ0個、一部完了、全完了）
- フィルター判定ロジックのテスト

---

## 5. ファイル変更一覧

| 操作 | ファイル |
| --- | --- |
| 新規 | `Sources/Models/TaskFilter.swift` |
| 修正 | `Sources/Models/Task.swift`（`isCompleted` 追加） |
| 修正 | `Sources/Views/TaskListView.swift`（フィルターUI、`filteredTasks`） |
| 修正 | `Sources/Views/MainView.swift`（`selectedFilter` 状態管理） |
| 新規 | `Tests/TaskFilterTests.swift`（オプション） |

---

## 6. 注意事項

- **削除時のインデックス**: `onDelete` の `IndexSet` は `filteredTasks` のインデックス。`filteredTasks[offset]` を `deleteTask` に渡す。
- **SwiftData の @Query**: `tasks` は変更に応じて自動更新されるため、`filteredTasks` も再計算される。

---

## 7. 自己レビュー（標準コンポーネント観点）

| 項目 | レビュー結果 |
| --- | --- |
| フィルター | ✅ `Picker` の標準スタイル（menu）を Menu 内で使用。 |
| 空状態 | ✅ `ContentUnavailableView` を使用。 |
| 状態管理 | ✅ `@State` と `@Query` のみ。 |
| 避けるもの | カスタムドロップダウン、独自空状態メッセージ View |
