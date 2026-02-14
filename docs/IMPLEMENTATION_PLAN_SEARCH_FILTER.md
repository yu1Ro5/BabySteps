# タスク検索・フィルター機能 実装計画

## 1. 概要

タスク一覧画面に検索とフィルター機能を追加し、ユーザーがタスクを効率的に絞り込めるようにする。

---

## 2. 機能仕様

### 2.1 検索

| 項目 | 内容 |
|------|------|
| 対象 | タスクのタイトル（`Task.title`） |
| 方式 | 部分一致（大文字小文字を区別しない） |
| UI | ナビゲーションバー下の検索バー（`searchable` または `TextField`） |
| 空文字 | 検索語が空の場合は全件表示 |

### 2.2 フィルター

| フィルター | 条件 | 説明 |
|------------|------|------|
| **すべて** | 全タスク | デフォルト |
| **進行中** | ステップが1つ以上あり、かつ未完了のステップが1つ以上ある | 着手済みで未完了 |
| **完了** | ステップが1つ以上あり、かつ全ステップが完了 | 全てのステップ完了 |
| **未着手**（オプション） | ステップが0個 | ステップ未追加 |

**補足**: ステップ0個のタスクは「未着手」として扱う。Phase 1では「すべて」「進行中」「完了」の3つで実装し、必要に応じて「未着手」を追加する。

---

## 3. 技術方針

### 3.1 データフロー

```
@Query(tasks) → 全タスク取得
       ↓
[View層でフィルタ]
  - 検索: title.localizedCaseInsensitiveContains(searchText)
  - フィルター: ステータスに応じて tasks を絞り込み
       ↓
filteredTasks → List に表示
```

**理由**: `@Query` は全件取得のままにし、検索・フィルターは View 層で行う。

- SwiftData の `#Predicate` で動的検索語を扱うと複雑になりやすい
- タスク数は通常そこまで多くない想定
- 実装がシンプルでテストしやすい

### 3.2 状態管理

| 状態 | 型 | 保持場所 |
|------|-----|----------|
| 検索語 | `String` | `TaskListView` の `@State` |
| フィルター種別 | `TaskFilter` enum | `TaskListView` の `@State` |

---

## 4. 実装タスク

### Phase 1: コア実装

#### 4.1 モデル・型定義

**ファイル**: `Sources/Models/TaskFilter.swift`（新規）

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

追加するメソッド:

```swift
/// タスクが「完了」かどうか（ステップが1つ以上かつ全完了）
func isTaskCompleted(_ task: Task) -> Bool

/// タスクが「進行中」かどうか（ステップありかつ未完了あり）
func isTaskInProgress(_ task: Task) -> Bool

/// タスクが「未着手」かどうか（ステップ0個）
func isTaskNotStarted(_ task: Task) -> Bool
```

または、`Task` モデルに computed property を追加:

```swift
// Task.swift
var isCompleted: Bool {
    !steps.isEmpty && steps.allSatisfy { $0.isCompleted }
}
```

**推奨**: モデルに `isCompleted` を追加し、ViewModel のフィルター用メソッドは `[Task]` をフィルタするユーティリティとして実装。

#### 4.3 View 修正

**ファイル**: `Sources/Views/TaskListView.swift`

1. **状態追加**
   - `@State private var searchText = ""`
   - `@State private var selectedFilter: TaskFilter = .all`

2. **フィルタ済みタスクの計算**
   - `private var filteredTasks: [Task]`（computed property）
   - 検索: `searchText.isEmpty || task.title.localizedCaseInsensitiveContains(searchText)`
   - フィルター: `selectedFilter` に応じて `tasks` を絞り込み

3. **UI 追加**
   - 検索: `.searchable(text: $searchText, prompt: "タスクを検索")`
   - フィルター: `Picker` または `Menu` を toolbar に配置

4. **List のデータソース変更**
   - `ForEach(tasks, ...)` → `ForEach(filteredTasks, ...)`
   - `onDelete` の `offsets` は `filteredTasks` に対するインデックスなので、`tasks` の実インデックスに変換する必要あり
   - または `filteredTasks` の要素から `Task` を取得して削除（`viewModel?.deleteTask(filteredTasks[index])`）

**削除時の注意**: `filteredTasks` は表示用の配列なので、`onDelete(perform: deleteTasks)` では `filteredTasks[offset]` を削除対象にする。`tasks` のインデックス変換は不要。

#### 4.4 プロジェクト設定

**ファイル**: `project.yml`

- `Sources/Models/TaskFilter.swift` は `Sources` 配下に置けば XcodeGen が自動で含める（`path: Sources` でグループ指定されているため、新規ファイル追加後 `xcodegen generate` を実行）

---

### Phase 2: UI 調整・アクセシビリティ

#### 4.5 検索バー

- `searchable` を使用（iOS 15+）
- プレースホルダー: 「タスクを検索」
- アクセシビリティラベルを付与

#### 4.6 フィルターピッカー

- `Picker(selection: $selectedFilter, ...)` を toolbar に配置
- スタイル: `Menu` または `SegmentedPickerStyle`（横並び）
- アクセシビリティ: 「フィルター: すべて / 進行中 / 完了」

#### 4.7 空状態

- 検索・フィルター結果が0件の場合のメッセージ表示
- 例: 「該当するタスクがありません」

---

### Phase 3: テスト

#### 4.8 ユニットテスト

**ファイル**: `Tests/TaskFilterTests.swift` または `Tests/TaskViewModelFilterTests.swift`

- `Task.isCompleted` のテスト（ステップ0個、一部完了、全完了）
- フィルター判定ロジックのテスト
- 検索の絞り込みロジックのテスト（ViewModel に検索・フィルター用メソッドを切り出した場合）

---

## 5. ファイル変更一覧

| 操作 | ファイル |
|------|----------|
| 新規 | `Sources/Models/TaskFilter.swift` |
| 修正 | `Sources/Models/Task.swift`（`isCompleted` 追加） |
| 修正 | `Sources/Views/TaskListView.swift`（検索・フィルターUI、`filteredTasks`） |
| 新規 | `Tests/TaskFilterTests.swift`（オプション） |

---

## 6. 実装順序

1. `TaskFilter` enum を定義
2. `Task` に `isCompleted` を追加
3. `TaskListView` に `filteredTasks` と検索・フィルター状態を追加
4. `taskList` を `filteredTasks` ベースに変更
5. `.searchable` とフィルター Picker の UI を追加
6. 空状態の表示を追加
7. ユニットテストを追加（任意）
8. `xcodegen generate` 実行、ビルド・動作確認

---

## 7. 注意事項

- **削除時のインデックス**: `onDelete` の `IndexSet` は `filteredTasks` のインデックス。`filteredTasks[offset]` を `deleteTask` に渡す。
- **SwiftData の @Query**: `tasks` は変更に応じて自動更新されるため、`filteredTasks` も再計算される。
- **検索のパフォーマンス**: タスク数が数百を超える場合は、デバウンスや `@Query` の predicate 検討を検討するが、現状は View 層フィルタで十分。
