# 変更レビュー（再実施）：MainView 採用およびボトムバー構成

## 1. 変更履歴の概要

| 変更 | 内容 |
|------|------|
| 1 | フィルターとプラスボタンをツールバーで分離（左/右） |
| 2 | メールアプリ風レイアウト：ボトムバー追加 |
| 3 | ボトムバーを各ビューに委譲（TaskListView: フィルター+タブ+プラス、ActivityView: タブのみ） |
| 4 | AppTab を BabyStepsApp に定義、MainView 維持（方針B） |
| 5 | 検索機能をドキュメントから削除 |
| 6 | ActivityView の force unwrap を修正、TabBarButton 共通化、README 更新 |

---

## 2. 現状のアーキテクチャ

```text
BabyStepsApp
  └── MainView (selectedTab, selectedFilter, showingAddTask)
        └── TabView (ツールバー非表示)
              ├── TaskListView
              │     └── ボトムバー: [フィルター] [TabBarButton×2] [プラス]
              └── ActivityView (lazy load)
                    └── ボトムバー: [TabBarButton×2]
```

**評価**: 関心の分離が明確。MainView がタブ・状態を一元管理し、各ビューが自身のボトムバーを持つ構成で一貫している。

---

## 3. コード品質

### 3.1 良い点

| 項目 | 評価 |
|------|------|
| 状態の流れ | MainView → Binding で子ビューに渡しており、単一方向で分かりやすい |
| ボトムバー配置 | TaskListView はフィルター+タブ+プラス、ActivityView はタブのみで要件通り |
| 共通コンポーネント | TabBarButton でタブボタンの重複を解消 |
| Force unwrap | ActivityView の `date(byAdding:)` を guard/break で安全に処理 |
| プレビュー | TaskListView の PreviewWrapper で Binding を正しく渡している |
| 空状態 | `emptyStateDescription` がフィルターのみに言及しており整合 |
| アクセシビリティ | TaskRowView に accessibilityLabel/Hint を設定 |

### 3.2 残存する改善候補

- 特になし（未使用の ActivityViewModel を削除済み）

---

## 4. ドキュメントの整合性

| ファイル | 状態 |
|----------|------|
| `docs/IMPLEMENTATION_PLAN_FILTER.md` | フィルターのみ記載、現状に整合 |
| `README.md` | プロジェクト構造を MainView、ActivityView、Components 含め更新済み |
| `docs/MAINVIEW_OPTIONS.md` | 方針B 採用済み |
| `docs/REVIEW_MAINVIEW_CHANGES.md` | 本レビュー |

---

## 5. 動作・エッジケース

| ケース | 確認結果 |
|--------|----------|
| タスクタブ → アクティビティタブ | TabBarButton で切り替え可能 |
| アクティビティタブ → タスクタブ | TabBarButton で切り替え可能 |
| フィルター変更 | Menu の Picker で選択、filteredTasks に即反映 |
| プラスボタン | タスク追加シート表示、作成後に `showingAddTask = false` で閉じる |
| ActivityView の lazy load | `selectedTab == .activity` 時のみ生成され、パフォーマンスに配慮 |
| 日付ループの安全終了 | `date(byAdding:)` が nil を返した場合に break でループ脱出 |

---

## 6. 総合評価

| 観点 | 評価 |
|------|------|
| アーキテクチャ | ◎ MainView 維持により関心の分離が明確 |
| 要件充足 | ◎ タスクリスト: フィルター+タブ+プラス、アクティビティ: タブのみ |
| コード品質 | ◎ 前回指摘事項（force unwrap、tabButton 重複、README）は解消 |
| ドキュメント | ◎ 計画書・README を現状に合わせて更新済み |

---

## 7. 推奨アクション

- 特になし（未使用の ActivityViewModel を削除済み）
