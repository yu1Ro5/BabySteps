# 「Unknown model version」エラーの原因と対策

## エラー

```
Cannot use staged migration with an unknown model version.
```

## 原因

| 要因 | 説明 |
| --- | --- |
| **既存ストア** | デバイスに以前のバージョンのアプリで作成された SwiftData ストアが存在する |
| **バージョン不一致** | そのストアは `SchemaMigrationPlan` 導入前に作成され、暗黙のスキーマでバージョンが付与されている |
| **計画との不整合** | `SchemaMigrationPlan` の SchemaV1 / SchemaV2 のいずれとも、既存ストアのバージョンが一致しない |

## 実施した対策

### SchemaV1 を既存ストアに合わせる

既存ストアは `Task.order: Int?` で作成されているため、SchemaV1 の Task にも `order: Int?` を追加した。

- **SchemaV1**: `order: Int?`（既存ストアと一致）
- **SchemaV2**: `order: Int`（必須）
- **マイグレーション**: `didMigrate` で `createdAt` 順に `order` を付与

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
