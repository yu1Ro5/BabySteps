# 変更レビュー：MainView 採用（方針B）およびボトムバー構成

## 1. 変更履歴の概要

| 変更 | 内容 |
|------|------|
| 1 | フィルターとプラスボタンをツールバーで分離（左/右） |
| 2 | メールアプリ風レイアウト：ボトムバー追加 |
| 3 | ボトムバーを各ビューに委譲（TaskListView: フィルター+タブ+プラス、ActivityView: タブのみ） |
| 4 | AppTab を BabyStepsApp に定義、MainView 維持（方針B） |

---

## 2. 現状のアーキテクチャ

```text
BabyStepsApp
  └── MainView (selectedTab, selectedFilter, showingAddTask)
        └── TabView (ツールバー非表示)
              ├── TaskListView
              │     └── ボトムバー: [フィルター] [タブ] [プラス]
              └── ActivityView (lazy load)
                    └── ボトムバー: [タブ]
```

**評価**: 関心の分離が明確。MainView がタブ・状態を一元管理し、各ビューが自身のボトムバーを持つ構成で一貫している。

---

## 3. コード品質

### 3.1 良い点

| 項目 | 評価 |
|------|------|
| 状態の流れ | MainView → Binding で子ビューに渡しており、単一方向で分かりやすい |
| ボトムバー配置 | TaskListView はフィルター+タブ+プラス、ActivityView はタブのみで要件通り |
| プレビュー | TaskListView の PreviewWrapper で Binding を正しく渡している |
| 空状態 | `emptyStateDescription` がフィルターのみに言及しており整合 |

### 3.2 改善候補

| 項目 | 場所 | 内容 |
|------|------|------|
| コード重複 | TaskListView / ActivityView | `tabButton` が両方に同じ実装。共通化すると保守性向上 |
| Force unwrap | ActivityView L119 | `calendar.date(byAdding:...)!`。AGENTS.md の「force unwrap を避ける」方針に反する |
| ドキュメント | IMPLEMENTATION_PLAN_FILTER.md | フィルターのみの実装計画に更新済み |

---

## 4. ドキュメントの整合性

### 4.1 更新が必要なドキュメント

| ファイル | 現状 | 推奨 |
|----------|------|------|
| `docs/IMPLEMENTATION_PLAN_FILTER.md` | フィルターのみ記載 | 現状に整合 |
| `README.md` | プロジェクト構造に MainView、ActivityView、Activity フォルダが未記載 | 現行構成に合わせて更新 |

### 4.2 整合しているドキュメント

- `docs/MAINVIEW_OPTIONS.md` - 方針比較（方針B 採用済み）
- `AGENTS.md` - アーキテクチャ・規約と矛盾なし

---

## 5. 動作・エッジケース

| ケース | 確認結果 |
|--------|----------|
| タスクタブ → アクティビティタブ | タブボタンで切り替え可能 |
| アクティビティタブ → タスクタブ | タブボタンで切り替え可能 |
| フィルター変更 | Menu の Picker で選択、filteredTasks に即反映 |
| プラスボタン | タスク追加シート表示、作成後に `showingAddTask = false` で閉じる |
| ActivityView の lazy load | `selectedTab == .activity` 時のみ生成され、パフォーマンスに配慮 |

---

## 6. 総合評価

| 観点 | 評価 |
|------|------|
| アーキテクチャ | ◎ MainView 維持により関心の分離が明確 |
| 要件充足 | ◎ タスクリスト: フィルター+タブ+プラス、アクティビティ: タブのみ |
| コード品質 | ○ 軽微な改善候補あり（tabButton 重複、force unwrap） |
| ドキュメント | ○ 計画書をフィルターのみに更新済み |

---

## 7. 推奨アクション（優先度順）

1. ~~**高**: `IMPLEMENTATION_PLAN_SEARCH_FILTER.md` を現状に合わせて更新~~ → 完了（`IMPLEMENTATION_PLAN_FILTER.md` に置換済み）
2. **中**: ActivityView の force unwrap を安全な処理に置き換え
3. **低**: `tabButton` を共通コンポーネントに抽出（重複削減）
4. **低**: README のプロジェクト構造を現行構成に更新
