# マイグレーション テスト計画

CI でマイグレーションをテストするための計画。

---

## 1. テスト可否

結論: 可能。

- CI は macOS ランナーで `xcodebuild test` を実行
- ユニットテスト内でファイルベースのストアを作成し、マイグレーションを検証できる

---

## 2. テストシナリオ

| シナリオ | 内容 | 検証内容 |
| --- | --- | --- |
| **A: 新規インストール** | 空ストアで SchemaLatest を開く | マイグレーション不要で起動できる |
| **B: V1 → V2 マイグレーション** | V1 スキーマのストアを作成し、MigrationPlan で開く | マイグレーション成功、order が付与される |
| **C: 既存テスト** | TaskViewModelTests 等 | マイグレーション計画付きコンテナで既存テストが通る |

---

## 3. 実装方針

### 3.1 シナリオ A（in-memory）

既存の `TestHelpers.makeInMemoryContainer()` が該当。in-memory は空ストアとして V2 で作成される。**マイグレーションは発生しない**。新規インストール時の動作を検証する。

### 3.2 シナリオ B（ファイルベース・必須）

マイグレーションは**ファイルベースのストア**でのみ発生する。in-memory では閉じたストアを再オープンできないため、**MigrationPlanTests はファイルベースで実装する**。効果: V1→V2 の実際のマイグレーション経路を検証できる。

1. `TestHelpers.makeV1Store(at:)` で V1 のみの ModelContainer を作成（MigrationPlan なし）
2. SchemaV1.Task を挿入し、`order = nil` を設定して保存
3. コンテナを破棄（スコープ外で解放）
4. `TestHelpers.openWithMigrationPlan(url:)` で同じ URL を MigrationPlan 付きで開く
5. Task を取得し、全件に `order` が 0, 1, ... と付与されていることを検証

### 3.3 V1 ストアの作成

`ModelContainer(for: Schema(versionedSchema: SchemaV1.self), configurations: [config])` で MigrationPlan なしの単一スキーマコンテナを作成。これにより V1 バージョン識別子付きのストアが作成される。

### 3.4 SchemaV1 の order

SchemaV1.Task は `order` を持たない（App Store 版 0.0.4-4 以前と一致）。SchemaV2.order に `@Attribute(.defaultValue(0))` を設定し、didMigrate で createdAt 順に付与する。

---

## 4. 実装ファイル

| ファイル | 内容 |
| --- | --- |
| `Tests/TestHelpers.swift` | `makeV1Store(at:)`, `openWithMigrationPlan(url:)` |
| `Tests/MigrationPlanTests.swift` | `testMigrationFromV1ToV2` |

---

## 5. フォールバック

V1 ストア作成が CI で失敗する場合（例: ModelConfiguration API 差異）:

- ドキュメントで手動検証手順を記載
- または、マイグレーションロジック（willMigrate の order 付与）を ViewModel 等に切り出し、そのユニットテストで代替

---

## 6. 参考

- [SwiftData Migration Testing](https://developer.apple.com/documentation/swiftdata/migrating-your-swiftdata-models)
- 既存 TestHelpers は in-memory + MigrationPlan で新規ストアを扱っている
