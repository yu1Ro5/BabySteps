# SwiftData マイグレーションエラーの原因と対策

## エラー 1: Unknown model version

```
Cannot use staged migration with an unknown model version.
```

### 原因

既存ストアのバージョンが `SchemaMigrationPlan` のいずれとも一致しない。

### 対策

SchemaV1 に `order: Int?` を追加し、既存ストアと一致させる。

---

## エラー 2: Missing attribute values on mandatory destination attribute

```
Validation error missing attribute values on mandatory destination attribute
entity=Task, attribute=order
```

### 原因

| 要因 | 説明 |
| --- | --- |
| **コピー順序** | マイグレーションは V1 → V2 のデータコピーを **didMigrate より前** に実行する |
| **nil の扱い** | V1 の Task で `order == nil` のレコードがある |
| **必須属性** | V2 の Task は `order: Int`（必須）のため、nil をコピーできない |

### 対策

**willMigrate** で、マイグレーション実行前に V1 の全 Task に `order` を付与する。

```swift
willMigrate: { context in
    let descriptor = FetchDescriptor<SchemaV1.Task>(
        sortBy: [SortDescriptor(\.createdAt, order: .forward)]
    )
    let tasks = try context.fetch(descriptor)
    for (index, task) in tasks.enumerated() {
        task.order = index
    }
    try context.save()
}
```

これにより、V1 → V2 のコピー時点で全タスクに `order` が入り、検証エラーを防ぐ。

---

## それでも解消しない場合

### 1. アプリの削除と再インストール（開発時）

シミュレータ／実機でアプリを削除し、再インストールしてストアを初期化する。

### 2. SchemaMigrationPlan を使わない方式に戻す

既存ユーザーが多く、マイグレーションが難しい場合は、以下に戻す選択肢がある。

- `ModelContainer(for: [Task.self, TaskStep.self])` のみ使用（`migrationPlan` なし）
- `Task.order` を `Int?` のまま維持
- `backfillTaskOrderIfNeeded` で並び順を設定

### 3. ストアのリセット（開発時のみ）

```swift
// 開発時のみ: ストアを削除して再作成
let storeURL = config.url
try? FileManager.default.removeItem(at: storeURL)
```

## 参考

- [SwiftData Migration - Apple Developer](https://developer.apple.com/documentation/swiftdata/migrating-your-swiftdata-models)
- 既存ストアのスキーマは、`SchemaMigrationPlan` 導入前のモデル定義に依存する
