# タスク・ステップ並び替え + テスト強化 実装計画

方針 D: 並び替え機能の実装とテスト強化を並行して進める。

---

## Part 1: タスク・ステップの並び替え（ドラッグ＆ドロップ）

### 1.1 設計方針

| 項目 | 方針 |
| --- | --- |
| タスク並び替え | `List` + `.onMove(perform:)`（SwiftUI 標準） |
| ステップ並び替え | 別シート内で `List` + `.onMove`（LazyVGrid はタスク行では維持） |
| タスク順序 | `Task` に `order` を追加し、`@Query` で `order` ソート |
| ステップ順序 | 既存の `TaskStep.order` を更新 |
| マイグレーション | 既存タスクに `createdAt` ベースの order をバックフィル |

---

### 1.2 実装手順

#### Step 1: Task モデルに order を追加

**ファイル**: `Sources/Models/Task.swift`

```swift
@Model
final class Task {
    var id: UUID
    var title: String
    var createdAt: Date
    /// 表示順序（0から開始、小さいほど上に表示）
    var order: Int
    var steps: [TaskStep]

    init(title: String) {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.order = 0  // 新規タスクは末尾に追加するため、addTask 時に最大値+1 を設定
        self.steps = []
    }
    // ... 既存プロパティ・メソッド
}
```

**注意**: SwiftData の `@Model` にプロパティを追加すると、デフォルト値がある限り既存データは自動マッピングされる場合がある。`order` のデフォルトを 0 にし、初回起動時にバックフィルする方針を推奨。

---

#### Step 2: TaskViewModel に並び替えメソッドを追加

**ファイル**: `Sources/ViewModels/TaskViewModel.swift`

```swift
// MARK: - Reorder

/// タスクの順序を変更する（filteredTasks のインデックスベース）
/// - Parameters:
///   - tasks: 表示中のタスク配列（フィルター適用後）
///   - source: 移動元の IndexSet
///   - destination: 移動先のインデックス
func moveTasks(_ tasks: [Task], from source: IndexSet, to destination: Int) {
    var reordered = tasks
    reordered.move(fromOffsets: source, toOffset: destination)

    for (index, task) in reordered.enumerated() {
        task.order = index
    }
    try? modelContext.save()
}

/// タスク内のステップの順序を変更する
/// - Parameters:
///   - task: 対象タスク
///   - source: 移動元の IndexSet
///   - destination: 移動先のインデックス
func reorderSteps(in task: Task, from source: IndexSet, to destination: Int) {
    let sortedSteps = task.steps.sorted { $0.order < $1.order }
    var reordered = sortedSteps
    reordered.move(fromOffsets: source, toOffset: destination)

    for (index, step) in reordered.enumerated() {
        step.order = index
    }
    try? modelContext.save()
}
```

---

#### Step 3: createTaskWithSteps で order を設定

新規タスク作成時、既存タスクの最大 order + 1 を設定する。

**ファイル**: `Sources/ViewModels/TaskViewModel.swift`

```swift
func createTaskWithSteps(title: String, stepCount: Int) -> Task {
    let tasks = (try? fetchTasks()) ?? []
    let maxOrder = tasks.map(\.order).max() ?? -1

    let task = Task(title: title)
    task.order = maxOrder + 1
    modelContext.insert(task)
    // ... 既存のステップ作成処理
}
```

---

#### Step 4: TaskListView の @Query を order でソート

**ファイル**: `Sources/Views/TaskListView.swift`

```swift
@Query(sort: \Task.order, order: .forward) private var tasks: [Task]
```

---

#### Step 5: TaskListView に onMove を追加

**ファイル**: `Sources/Views/TaskListView.swift`

```swift
List {
    ForEach(filteredTasks, id: \.id) { task in
        TaskRowView(...)
    }
    .onDelete(perform: deleteTasks)
    .onMove { source, destination in
        guard selectedFilter == .all else { return }
        viewModel?.moveTasks(filteredTasks, from: source, to: destination)
    }
}
```

※ `selectedFilter == .all` のときのみ EditButton を表示するため、実質的には「すべて」表示時のみ並び替え可能。`onMove` 内の guard は二重チェックとして残す。

**注意**: `List` で編集モードを有効にする必要がある。ツールバーに EditButton を追加するか、ナビゲーションタイトル横に編集ボタンを配置する。

```swift
.toolbar {
    if selectedFilter == .all {
        EditButton()
    }
}
```

**重要（フィルタ時の並び替え）**: `filteredTasks` は「進行中」「完了」フィルタ時に `tasks` のサブセットになる。この状態で `moveTasks` に `filteredTasks` を渡し、そのインデックスで `task.order = index` とすると、**全タスクの order が破壊される**（例: 完了タスク 2 件の order を 0, 1 にすると、進行中タスクの order と重複）。**対策**: フィルタが「すべて」のときのみ `onMove` を有効にする。`selectedFilter == .all` のときだけ `.onMove` を付与し、それ以外は EditButton を非表示にする。

---

#### Step 6: 既存タスクの order バックフィル

**ファイル**: `Sources/Views/TaskListView.swift` の `onAppear` 内

```swift
// 既存タスクに order が未設定の場合のバックフィル（createdAt 順で付与）
if !didBackfillOrder {
    didBackfillOrder = true
    backfillTaskOrder()
}
```

```swift
private func backfillTaskOrder() {
    let descriptor = FetchDescriptor<Task>(
        sortBy: [SortDescriptor(\.createdAt, order: .forward)]
    )
    guard let allTasks = try? modelContext.fetch(descriptor), !allTasks.isEmpty else {
        return
    }
    var needsSave = false
    for (index, task) in allTasks.enumerated() {
        if task.order != index {
            task.order = index
            needsSave = true
        }
    }
    if needsSave { try? modelContext.save() }
}
```

`@State private var didBackfillOrder = false` を追加。

---

#### Step 7: TaskRowView のステップ表示を List に変更

**現状**: `LazyVGrid` で 5 列のチェックボックス

**変更後**: `List` で 1 行 1 ステップ、ドラッグハンドル付き。編集モード時のみ並び替え可能とする。

**ファイル**: `Sources/Views/TaskRowView`（TaskListView.swift 内）

```swift
// ステップ一覧
if !task.steps.isEmpty {
    List {
        ForEach(task.steps.sorted(by: { $0.order < $1.order }), id: \.id) { step in
            Button(action: {
                guard let viewModel = viewModel else { return }
                viewModel.toggleStepCompletion(step)
            }) {
                HStack {
                    Image(systemName: step.isCompleted ? "checkmark.square.fill" : "square")
                        .foregroundColor(step.isCompleted ? .green : .gray)
                        .font(.title2)
                    Text("ステップ \(step.order + 1)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(viewModel == nil)
        }
        .onMove { source, destination in
            viewModel?.reorderSteps(in: task, from: source, to: destination)
        }
    }
    .listStyle(.plain)
    .frame(minHeight: 44 * CGFloat(min(task.steps.count, 5)))  // 高さ制限でコンパクトに
}
```

**課題**: `TaskRowView` 内の `List` に `.onMove` を付けると、親の `List`（タスク一覧）とネストした `List` が競合する可能性がある。SwiftUI では `List` のネストが制限される場合がある。

**代替案**: ステップ並び替えを別シートで行う。

- タスク行をタップで「ステップ編集」シートを開く
- シート内で `List` + `.onMove` でステップ並び替え

この方が確実で、UI の競合も避けられる。実装計画を修正する。

---

#### Step 7（修正）: ステップ並び替えをシートで行う

1. タスク行に「並び替え」ボタン（例: `line.3.horizontal`）を追加
2. タップで「ステップ並び替え」シートを表示
3. シート内で `List` + `ForEach` + `.onMove` で並び替え

**シート用 View**（`TaskListView.swift` 内または別ファイル）:

```swift
struct StepReorderSheet: View {
    let task: Task
    let viewModel: TaskViewModel?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(task.steps.sorted(by: { $0.order < $1.order }), id: \.id) { step in
                    HStack {
                        Image(systemName: step.isCompleted ? "checkmark.square.fill" : "square")
                            .foregroundColor(step.isCompleted ? .green : .gray)
                        Text("ステップ \(step.order + 1)")
                    }
                }
                .onMove { source, destination in
                    viewModel?.reorderSteps(in: task, from: source, to: destination)
                }
            }
            .navigationTitle("ステップの並び替え")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") { dismiss() }
                }
            }
        }
    }
}
```

**TaskRowView の変更**:

- `onReorderStep: () -> Void` コールバックを追加
- 既存の `onAddStep` の横に「並び替え」ボタン（`line.3.horizontal`）を配置し、タップで `onReorderStep` を呼ぶ
- ステップが 0 個の場合は並び替えボタンを非表示または無効化

**TaskListView の変更**:

- `@State private var stepReorderTask: Task?` を追加
- `TaskRowView` に `onReorderStep: { stepReorderTask = task }` を渡す
- `.sheet(item: $stepReorderTask) { task in StepReorderSheet(task: task, viewModel: viewModel) }` を追加
- `Task` が `Identifiable` に準拠していない場合は `extension Task: Identifiable {}` を追加（`id: UUID` があれば `Identifiable` 準拠可能）

---

### 1.3 ファイル変更一覧（並び替え）

| 操作 | ファイル |
| --- | --- |
| 修正 | `Sources/Models/Task.swift`（`order` 追加） |
| 修正 | `Sources/ViewModels/TaskViewModel.swift`（`moveTasks`, `reorderSteps`, `createTaskWithSteps` 修正） |
| 修正 | `Sources/Views/TaskListView.swift`（`@Query` 変更、`onMove`、`EditButton`、バックフィル、`StepReorderSheet`、`stepReorderTask`、`TaskRowView` に `onReorderStep` と並び替えボタン、フィルタ時は並び替え無効化） |

---

## Part 2: テスト強化

### 2.1 対象

| テスト対象 | 内容 |
| --- | --- |
| `Task.isCompleted` | ステップ 0 個、一部完了、全完了 |
| `Task` 進捗率 | `completedStepsCount`, `totalStepsCount` |
| フィルター判定 | `TaskFilter` に応じたタスクの分類 |
| `TaskViewModel` | `createTaskWithSteps`, `deleteTask`, `toggleStepCompletion`, `moveTasks`, `reorderSteps` |

---

### 2.2 テストの課題

- SwiftData の `@Model` は `ModelContext` が必要
- テストでは `ModelContainer` を in-memory で作成して `ModelContext` を取得する

---

### 2.3 実装手順

#### Step 1: テスト用ヘルパー

**ファイル**: `Tests/TestHelpers.swift`（新規）

```swift
import Foundation
import SwiftData
@testable import BabySteps

enum TestHelpers {
    static func makeInMemoryContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: Task.self, TaskStep.self,
            configurations: config
        )
    }
}
```

---

#### Step 2: Task モデルのテスト

**ファイル**: `Tests/TaskModelTests.swift`（新規）

```swift
import XCTest
@testable import BabySteps

final class TaskModelTests: XCTestCase {

    func testIsCompleted_emptySteps_returnsFalse() {
        let task = Task(title: "Test")
        XCTAssertFalse(task.isCompleted)
    }

    func testIsCompleted_allStepsCompleted_returnsTrue() {
        let task = Task(title: "Test")
        let step1 = TaskStep(order: 0)
        let step2 = TaskStep(order: 1)
        step1.isCompleted = true
        step2.isCompleted = true
        task.addStep(step1)
        task.addStep(step2)
        XCTAssertTrue(task.isCompleted)
    }

    func testIsCompleted_someStepsIncomplete_returnsFalse() {
        let task = Task(title: "Test")
        let step1 = TaskStep(order: 0)
        let step2 = TaskStep(order: 1)
        step1.isCompleted = true
        task.addStep(step1)
        task.addStep(step2)
        XCTAssertFalse(task.isCompleted)
    }

    func testCompletedStepsCount() {
        let task = Task(title: "Test")
        let step1 = TaskStep(order: 0)
        let step2 = TaskStep(order: 1)
        step1.isCompleted = true
        task.addStep(step1)
        task.addStep(step2)
        XCTAssertEqual(task.completedStepsCount, 1)
        XCTAssertEqual(task.totalStepsCount, 2)
    }
}
```

**注意**: `Task` と `TaskStep` は SwiftData の `@Model`。`ModelContext` なしでインスタンス化するとランタイムエラーになる可能性がある。**推奨**: `TaskModelTests` でも `TestHelpers.makeInMemoryContainer()` で `ModelContext` を用意し、`modelContext.insert(task)` してから検証する。または、`TaskViewModel.createTaskWithSteps` でタスクを作成し、そのタスクの `isCompleted` 等を検証する形で `TaskViewModelTests` に統合する。

**ModelContext 使用版の例**:

```swift
final class TaskModelTests: XCTestCase {
    var container: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        container = try TestHelpers.makeInMemoryContainer()
        modelContext = ModelContext(container)
    }

    func testIsCompleted_allStepsCompleted_returnsTrue() throws {
        let task = Task(title: "Test")
        modelContext.insert(task)
        for i in 0..<2 {
            let step = TaskStep(order: i)
            step.isCompleted = true
            task.addStep(step)
            modelContext.insert(step)
        }
        try modelContext.save()
        XCTAssertTrue(task.isCompleted)
    }
}
```

---

#### Step 3: TaskViewModel のテスト

**ファイル**: `Tests/TaskViewModelTests.swift`（新規）

```swift
import XCTest
import SwiftData
@testable import BabySteps

final class TaskViewModelTests: XCTestCase {

    var container: ModelContainer!
    var modelContext: ModelContext!
    var viewModel: TaskViewModel!

    override func setUpWithError() throws {
        container = try TestHelpers.makeInMemoryContainer()
        modelContext = ModelContext(container)
        viewModel = TaskViewModel(modelContext: modelContext)
    }

    override func tearDownWithError() throws {
        container = nil
        modelContext = nil
        viewModel = nil
    }

    func testCreateTaskWithSteps() throws {
        let task = viewModel.createTaskWithSteps(title: "My Task", stepCount: 3)
        XCTAssertEqual(task.title, "My Task")
        XCTAssertEqual(task.steps.count, 3)
        XCTAssertEqual(task.order, 0)
    }

    func testDeleteTask() throws {
        let task = viewModel.createTaskWithSteps(title: "To Delete", stepCount: 1)
        viewModel.deleteTask(task)
        let tasks = try viewModel.fetchTasks()
        XCTAssertTrue(tasks.isEmpty)
    }

    func testToggleStepCompletion() throws {
        let task = viewModel.createTaskWithSteps(title: "Toggle", stepCount: 1)
        let step = task.steps[0]
        XCTAssertFalse(step.isCompleted)
        viewModel.toggleStepCompletion(step)
        XCTAssertTrue(step.isCompleted)
        viewModel.toggleStepCompletion(step)
        XCTAssertFalse(step.isCompleted)
    }

    func testMoveTasks() throws {
        let t1 = viewModel.createTaskWithSteps(title: "A", stepCount: 1)
        let t2 = viewModel.createTaskWithSteps(title: "B", stepCount: 1)
        let t3 = viewModel.createTaskWithSteps(title: "C", stepCount: 1)
        let tasks = [t1, t2, t3]
        viewModel.moveTasks(tasks, from: IndexSet(integer: 0), to: 3)
        let sorted = tasks.sorted { $0.order < $1.order }
        XCTAssertEqual(sorted.map(\.title), ["B", "C", "A"])
    }

    func testReorderSteps() throws {
        let task = viewModel.createTaskWithSteps(title: "Steps", stepCount: 3)
        let steps = task.steps.sorted { $0.order < $1.order }
        viewModel.reorderSteps(in: task, from: IndexSet(integer: 0), to: 3)
        let reordered = task.steps.sorted { $0.order < $1.order }
        XCTAssertEqual(reordered[0].id, steps[1].id)
        XCTAssertEqual(reordered[1].id, steps[2].id)
        XCTAssertEqual(reordered[2].id, steps[0].id)
    }
}
```

---

#### Step 4: フィルター判定のテスト

**ファイル**: `Tests/TaskFilterTests.swift`（新規）

フィルター判定ロジックは `TaskListView` の `filteredTasks` にある。`Task.isCompleted` と「進行中」の条件（`!steps.isEmpty && !isCompleted`）をテストする。

```swift
import XCTest
@testable import BabySteps

final class TaskFilterTests: XCTestCase {

    func testAllFilter_includesAllTasks() {
        // filteredTasks のロジックを直接テストする代わりに、
        // Task の isCompleted が正しく動作することを確認
        // 実際のフィルタは View 層なので、モデルの条件だけテスト
        let task = Task(title: "Done")
        let step = TaskStep(order: 0)
        step.isCompleted = true
        task.addStep(step)
        XCTAssertTrue(task.isCompleted)
    }

    func testInProgressFilter_taskWithIncompleteSteps() {
        let task = Task(title: "In Progress")
        let step = TaskStep(order: 0)
        task.addStep(step)
        XCTAssertFalse(task.isCompleted)
        XCTAssertFalse(task.steps.isEmpty)
    }

    func testCompletedFilter_taskWithAllStepsCompleted() {
        let task = Task(title: "Completed")
        let step = TaskStep(order: 0)
        step.isCompleted = true
        task.addStep(step)
        XCTAssertTrue(task.isCompleted)
    }
}
```

---

#### Step 5: project.yml にテストファイルを追加

**ファイル**: `project.yml`

`Tests` は `type: group` で `path: Tests` を指定しているため、Tests フォルダ内の Swift ファイルは自動的に含まれる（XcodeGen の sources がディレクトリを再帰的に含む場合）。確認のため、`Tests` の sources が正しく設定されているか確認する。

---

### 2.4 ファイル変更一覧（テスト）

| 操作 | ファイル |
| --- | --- |
| 新規 | `Tests/TestHelpers.swift` |
| 新規 | `Tests/TaskModelTests.swift` |
| 新規 | `Tests/TaskViewModelTests.swift` |
| 新規 | `Tests/TaskFilterTests.swift` |
| 修正 | `BabyStepsTests.swift`（既存のプレースホルダーは残すか、削除して新規テストに統合） |

---

## Part 3: 実装順序（推奨）

1. **Task に order 追加** + バックフィル
2. **TaskViewModel** に `moveTasks`, `reorderSteps` 追加、`createTaskWithSteps` 修正
3. **TaskListView** の `@Query` 変更、タスク `onMove`、`EditButton` 追加
4. **StepReorderSheet** 作成、TaskRowView に並び替えボタン追加
5. **TestHelpers** 作成
6. **TaskModelTests** 作成
7. **TaskViewModelTests** 作成（`moveTasks`, `reorderSteps` 含む）
8. **TaskFilterTests** 作成
9. ビルド・テスト実行で動作確認

---

## Part 4: 注意事項

- **SwiftData マイグレーション**: `Task` に `order` を追加した際、既存アプリのデータで `order` が未設定の場合、バックフィルで対応する。
- **List のネスト**: iOS では `List` 内に `List` をネストすると、内側の `List` が `ListStyle.plain` で表示される。タスク一覧の各セルにステップの `List` を入れると、セルが非常に長くなる。そのため、ステップ並び替えはシートで行う設計とした。
- **EditButton**: タスク並び替え時、ユーザーが Edit をタップして編集モードにしないとドラッグハンドルが表示されない。これは SwiftUI の標準挙動。

---

## Part 5: セルフレビュー

### 5.1 設計・ロジックの検証

| 項目 | レビュー結果 | 対応 |
| --- | --- | --- |
| フィルタ時の moveTasks | ❌ 当初、filteredTasks のインデックスで order を上書きすると全タスクの order が破壊される | ✅ Step 5 に「フィルタがすべてのときのみ onMove 有効」を追記 |
| 設計方針の表 | ❌ ステップ並び替えが「LazyVGrid から List」と記載されていたが、実際はシート | ✅ 「別シート内で List + onMove」に修正 |
| TaskRowView の状態 | ❌ stepReorderTask の管理場所が不明確 | ✅ TaskListView の `stepReorderTask`、`onReorderStep` コールバックを明記 |
| fetchTasks のソート | ✅ maxOrder は全タスクから取得するため、fetchTasks のソートは影響しない | 変更不要 |

### 5.2 実装漏れ・曖昧さの解消

| 項目 | レビュー結果 | 対応 |
| --- | --- | --- |
| StepReorderSheet の表示 | ❌ sheet のトリガーが不明 | ✅ `.sheet(item: $stepReorderTask)` と `onReorderStep` を明記 |
| Task の Identifiable | ❓ sheet(item:) に必要 | ✅ 準拠していない場合は extension を追加する旨を記載 |
| テストの @Model | ❌ ModelContext なしで Task を生成するとエラーになる可能性 | ✅ TaskModelTests で ModelContext 使用を推奨、コード例を追加 |
| EditButton の表示条件 | ❌ フィルタ時は非表示にするが、toolbar の条件が未記載 | ✅ 「selectedFilter == .all のときのみ」を Step 5 に追記 |

### 5.3 標準コンポーネント・一貫性（IMPLEMENTATION_PLAN_FILTER 準拠）

| 項目 | レビュー結果 |
| --- | --- |
| タスク並び替え | ✅ `List` + `.onMove`（SwiftUI 標準） |
| ステップ並び替え | ✅ シート内 `List` + `.onMove`（SwiftUI 標準） |
| 編集モード | ✅ `EditButton`（SwiftUI 標準） |
| 避けるもの | カスタムドラッグジェスチャー、独自並び替え UI |

### 5.4 残存リスク・要確認事項

| 項目 | 内容 |
| --- | --- |
| SwiftData スキーマ変更 | `Task` に `order` を追加した際、既存ユーザーの DB でマイグレーションが自動適用されるか要確認。デフォルト値 0 + バックフィルで対応可能な想定。 |
| XcodeGen と Tests | `Tests` フォルダの Swift ファイルは `sources: path: Tests` で自動含まれる。新規ファイル追加後は `xcodegen generate` を実行すること。 |
| Task の Identifiable | 現行コードで `sheet(item: $selectedTask)` が動作しているため、Task は既に Identifiable の可能性が高い。実装時に確認。 |
