# Task.order を Int（非オプショナル）にする改善計画

## 1. 問題

- **目標**: `Task.order` を `Int?` ではなく `Int` にしたい
- **エラー**: `Validation error missing attribute values on mandatory destination attribute`（Task.order）
- **原因**: 必須属性を追加した際、既存データに値がなく、SwiftData/Core Data のマイグレーションで値を埋められない

---

## 2. 推奨方針: C（明示的スキーマとマイグレーション計画）

### 2.1 方針 C を主軸とする理由

| 観点 | 内容 |
| --- | --- |
| **正攻法** | SwiftData の `SchemaMigrationPlan` による明示的マイグレーションが公式のアプローチ |
| **一括解決** | マイグレーション処理内で `createdAt` 順に 0, 1, 2, ... を付与でき、並び順も正しく設定できる |
| **将来の拡張** | スキーマバージョンを増やしていく形で、今後の変更にも同じパターンで対応可能 |

### 2.2 実装の流れ

1. `VersionedSchema` でスキーマバージョン（V1: order なし、V2: order あり）を定義
2. `SchemaMigrationPlan` でマイグレーション計画を定義
3. マイグレーション処理内で既存 Task に `createdAt` 順で order を付与
4. `ModelContainer` 作成時にマイグレーション計画を指定

### 2.3 実装例（概念）

```swift
// スキーマバージョン定義
enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [Task.self, TaskStep.self] }
    // Task に order なし
}

enum SchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] { [Task.self, TaskStep.self] }
    // Task に order: Int あり
}

// マイグレーション計画
struct BabyStepsMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [SchemaV1.self, SchemaV2.self] }
    static var stages: [MigrationStage] { [migrateV1toV2] }

    static let migrateV1toV2 = CustomMigrationStage(from: SchemaV1.self, to: SchemaV2.self) { context in
        // 既存 Task に createdAt 順で order を付与
        let descriptor = FetchDescriptor<Task>(sortBy: [SortDescriptor(\.createdAt, order: .forward)])
        guard let tasks = try? context.fetch(descriptor) else { return }
        for (index, task) in tasks.enumerated() {
            task.order = index
        }
        try? context.save()
    }
}

// BabyStepsApp での ModelContainer 作成
ModelContainer(
    for: [Task.self, TaskStep.self],
    migrationPlan: BabyStepsMigrationPlan.self,
    configurations: config
)
```

**注意**: 上記は概念例。SwiftData の `CustomMigrationStage`、`VersionedSchema` の実際の API や、マイグレーション処理内での `ModelContext` の取得方法は、実機・ドキュメントで要確認。

---

## 3. その他の方針と限界

### 3.1 方針 A: スキーマにデフォルト値を指定する

**内容**: `@Attribute(defaultValue: 0)` でマイグレーション時に既存レコードに 0 を自動適用する。

**限界**:

| 項目 | 内容 |
| --- | --- |
| **並び順の破綻** | 全タスクが `order = 0` になり、複数タスク間の並び替えができない |
| **バックフィル必須** | 結局 `backfillTaskOrderIfNeeded` で `createdAt` 順に 0, 1, 2, ... を再設定する必要がある |
| **役割** | マイグレーションのクラッシュ回避のみ。並び順の修正は別処理に依存 |

**結論**: 単体では不十分。バックフィルと組み合わせれば動作するが、方針 C の方が一貫している。

---

### 3.2 方針 B: 二段階マイグレーション

**内容**: Phase 1 で `Int?` + バックフィル、Phase 2 で `Int` に変更。

**課題**: SwiftData が `Int?` → `Int` のスキーマ変更を許容するか不明。Phase 2 で同様のエラーが出る可能性がある。

---

### 3.3 方針 D: アプリ起動前にマイグレーションを実行

**評価**: SwiftData は `ModelContainer` を開いた時点でマイグレーションが走るため、その前にストアを触るのは現実的ではない。

---

### 3.4 方針 E: Int? のまま運用

**内容**: モデルは `Int?` のまま、利用箇所で `?? 0` や `effectiveOrder` で扱う。

**評価**: マイグレーションエラーは避けられるが、型で「常に値がある」ことを表現できず、フォールバック対応が残る。

---

## 4. 推奨アクション

### ステップ 1: SwiftData のマイグレーション API を確認

1. [SchemaMigrationPlan](https://developer.apple.com/documentation/swiftdata/schemamigrationplan) のドキュメントを確認
2. [Migrating to SwiftData - WWDC](https://developer.apple.com/videos/play/wwdc2023/10187/) でマイグレーション例を確認
3. `VersionedSchema`、`CustomMigrationStage` の定義方法と利用可否を確認

### ステップ 2: 方針 C の実装

1. スキーマバージョン（V1, V2）を定義
2. マイグレーション計画とマイグレーション処理を実装
3. `BabyStepsApp` の `ModelContainer` 作成時にマイグレーション計画を指定
4. `Task.order` を `Int` に変更
5. `backfillTaskOrderIfNeeded` と `Task.migrateOrderIfNeeded` を削除（マイグレーションで代替）
6. `TaskViewModel.createTaskWithSteps` の `compactMap` を `map(\.order)` に戻す

### ステップ 3: フォールバック

方針 C の API が利用できない、または実装が困難な場合:

- **方針 B**（二段階マイグレーション）を検討
- それでも難しい場合は **方針 E**（`Int?` のまま運用）にフォールバック

---

## 5. 実装タスク一覧（方針 C 採用時）

| 順 | タスク |
| --- | --- |
| 1 | SwiftData の `SchemaMigrationPlan` 等の API を確認 |
| 2 | `VersionedSchema` で V1（order なし）、V2（order あり）を定義 |
| 3 | `SchemaMigrationPlan` とマイグレーション処理を実装 |
| 4 | `BabyStepsApp` で `ModelContainer` にマイグレーション計画を指定 |
| 5 | `Task.order` を `Int` に変更 |
| 6 | `backfillTaskOrderIfNeeded`、`Task.migrateOrderIfNeeded` を削除 |
| 7 | `TaskViewModel` の `compactMap` を `map(\.order)` に戻す |
| 8 | 既存データを持つシミュレータでマイグレーションを検証 |

---

## 6. 参考リンク

- [SwiftData Model - Apple Developer](https://developer.apple.com/documentation/swiftdata/model)
- [SchemaMigrationPlan - Apple Developer](https://developer.apple.com/documentation/swiftdata/schemamigrationplan)
- [Migrating to SwiftData - WWDC](https://developer.apple.com/videos/play/wwdc2023/10187/)
