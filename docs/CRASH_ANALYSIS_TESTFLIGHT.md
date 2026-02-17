# TestFlight クラッシュ分析

## 原因

| 項目 | 内容 |
| --- | --- |
| **クラッシュ箇所** | `BabyStepsApp.swift` 26行目、`modelContainer` 初期化時の `fatalError` |
| **直接原因** | `ModelContainer` 初期化が `throw` → `catch` で `fatalError` 実行 → `EXC_BREAKPOINT` |
| **根本原因** | SwiftData マイグレーション失敗。既存ストア（旧バージョン）と新スキーマ（SchemaMigrationPlan）の不整合 |

### 発生条件

- 過去バージョンをインストールしていた端末でアプリをアップデートした場合
- 既存ストアのスキーマバージョンが `SchemaV1` / `SchemaV2` と一致しない
- 例: "Unknown model version" や "missing attribute values" によりマイグレーション失敗

### なぜ TestFlight で顕在化するか

- 開発時はシミュレータ／実機をクリーンインストールすることが多く、既存ストアがない
- TestFlight 配布では、ユーザーが前バージョンからアップデートするため、既存ストアが残る

---

## 対策

### 1. 暫定対応（クラッシュ防止）

マイグレーション失敗時にストアを削除して再作成するフォールバックを実装。**データは失われる**が、クラッシュは防ぐ。

### 2. 正式対応（実装済み）

- SchemaV1 から `order` を削除し、App Store 版（0.0.4-4）のストア構造に一致
- SchemaV2.order に `@Attribute(.defaultValue(0))` を設定し、マイグレーション時のコピーを成功させる
- didMigrate で createdAt 順に order を付与
- ストア削除リカバリは最終手段として残す

### 3. エラーハンドリング改善（実装済み）

- マイグレーション失敗時に `fatalError` せず、ストア削除＋再試行を行う
- 再試行で新規ストアが作成され、クラッシュを防止
- **注意**: リカバリ時は既存データが失われる
