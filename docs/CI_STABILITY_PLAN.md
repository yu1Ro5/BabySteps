# CI 安定性向上計画：CoreData 初期化エラーとパフォーマンステスト対策

## 1. 現状の課題

| 課題 | 現象 | 影響 |
| --- | --- | --- |
| CoreData 初期化エラー | シミュレータ上で SwiftData ストア作成時に `Sandbox access to file-write-create denied`、`No such file or directory` が発生。リカバリで成功するが不安定 | 将来的にテスト失敗・フレークの原因になりうる |
| パフォーマンステストの変動 | `testPerformanceExample` の RSD が 125%（許容 10%）を超過。空の `measure { }` で測定値が極小 | 厳格な設定で失敗する可能性 |

---

## 2. 対策方針

### 2.1 CoreData 初期化エラー対策

**方針**: テスト実行時はディスク永続化を避け、メモリ内ストアを使用する。

**根拠**:

- ユニットテストでは永続化は不要。メモリ内ストアで十分
- シミュレータのサンドボックスやディレクトリ作成タイミングに依存しない
- SwiftData の `ModelContainer` は `inMemory` オプションをサポート

**実装案**:

1. **テスト検出**: `ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil` で XCTest 実行中かを判定
2. **条件分岐**: テスト時は `ModelContainer(for: [Task.self, TaskStep.self], inMemory: true)` を渡す
3. **本番**: 従来どおり `.modelContainer(for: [Task.self, TaskStep.self])` を使用

**変更対象**: `Sources/App/BabyStepsApp.swift`

```swift
var body: some Scene {
    WindowGroup {
        MainView()
            .modelContainer(for: [Task.self, TaskStep.self], inMemory: isRunningTests)
    }
}

private var isRunningTests: Bool {
    ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
}
```

※ `modelContainer(for:inMemory:)` は TaskListView の Preview で既に使用済み（`inMemory: true`）。

---

### 2.2 パフォーマンステスト対策

**方針**: 意味のないパフォーマンステストを削除または安定化する。

**選択肢**:

| 選択肢 | 内容 | 推奨度 |
| --- | --- | --- |
| A. 削除 | `testPerformanceExample` を削除。空の `measure` は価値がない | ◎ 推奨 |
| B. ベースライン設定 | `measure(options: XCTMeasureOptions())` でベースラインを設定し、変動を許容 | △ |
| C. 実測対象の追加 | 実際に計測したい処理（例: TaskViewModel の CRUD）を追加 | ○ 将来的に |

**推奨**: 選択肢 A。テンプレートのままの空テストは削除し、必要なパフォーマンステストは後から追加する。

**変更対象**: `Tests/BabyStepsTests.swift`

---

## 3. ワークフロー改善（オプション）

**現状**: テスト失敗時も `|| echo "..."` でステップを成功扱いにしている。

**推奨**: テスト失敗を検知できるようにする。

- CoreData 対策とパフォーマンステスト削除で安定化を図ったうえで、`|| echo` を外し、テスト失敗時にジョブを失敗させる
- シミュレータ起因のフレークが残る場合は、リトライや `continue-on-error` を検討

**変更対象**: `.github/workflows/ios-build.yml`

---

## 4. 実装順序

| 順序 | タスク | 優先度 | 見積もり |
| --- | --- | --- | --- |
| 1 | パフォーマンステスト削除（`testPerformanceExample`） | 高 | 小 |
| 2 | テスト時メモリ内 ModelContainer の適用 | 高 | 中 |
| 3 | ワークフローの失敗マスキング削除（テスト失敗を検知） | 中 | 小 |

---

## 5. 検証方法

1. **ローカル**: `xcodebuild test` を複数回実行し、安定して成功することを確認
2. **CI**: PR を作成し、複数回のワークフロー実行でエラー・警告が減っていることを確認
3. **ログ**: Step 10 のログに CoreData エラーが出ないことを確認

---

## 6. 参考

- [SwiftData ModelContainer](https://developer.apple.com/documentation/swiftdata/modelcontainer)
- [XCTest Performance Testing](https://developer.apple.com/documentation/xctest/performance_tests)
- AGENTS.md: "The CI workflow currently tolerates test failures due to simulator flakiness; for product changes, prefer making tests reliable rather than skipping."
