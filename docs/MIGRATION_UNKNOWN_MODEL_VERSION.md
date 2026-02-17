# SwiftData マイグレーションエラーの原因と対策

## エラー 1: Unknown model version

```text
Cannot use staged migration with an unknown model version.
```

### エラー 1 の原因

既存ストアのバージョンが `SchemaMigrationPlan` のいずれとも一致しない。

### エラー 1 の対策

SchemaV1 から `order` を削除し、App Store 版（0.0.4-4 以前）のストア構造に一致させる。

---

## エラー 2: Missing attribute values on mandatory destination attribute

```text
Validation error missing attribute values on mandatory destination attribute
entity=Task, attribute=order
```

### エラー 2 の原因

| 要因 | 説明 |
| --- | --- |
| **コピー順序** | マイグレーションは V1 → V2 のデータコピーを **didMigrate より前** に実行する |
| **nil の扱い** | V1 の Task で `order == nil` のレコードがある |
| **必須属性** | V2 の Task は `order: Int`（必須）のため、nil をコピーできない |

### エラー 2 の対策

1. **SchemaV2.order** に `@Attribute(.defaultValue(0))` を設定し、コピー時にデフォルトを使用
2. **didMigrate** で、コピー後に V2 の全 Task に `createdAt` 順で `order` を付与する

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
