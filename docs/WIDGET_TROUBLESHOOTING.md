# ウィジェット「ステップがありません」不具合 調査レポート

再インストールしてもウィジェットにデータが反映されない問題の原因調査結果。

---

## 1. データフロー（現状）

```text
アプリ起動
  → BabyStepsApp.modelContainer
  → appGroupContainer = containerURL(forSecurityApplicationGroupIdentifier: "group.com.yu1Ro5.BabySteps")
  → targetURL = appGroupContainer/default.store（nil なら legacyURL）
  → SwiftData が targetURL に読み書き

ウィジェット表示
  → ProgressTimelineProvider.modelContainer
  → containerURL = containerURL(forSecurityApplicationGroupIdentifier: "group.com.yu1Ro5.BabySteps")
  → nil の場合: modelContainer = nil → 空の ProgressEntry を返す → 「ステップがありません」
  → nil でない場合: storeURL = containerURL/default.store → 同じストアを開く
```

---

## 2. 想定される原因（コードベースから）

### 原因 A: ウィジェットで containerURL が nil（最有力）

**根拠**: `BabyStepsWidget.swift` の `fetchEntry()` は `modelContainer` が nil のとき、空の `ProgressEntry` を返す。`todayTotalCount == 0` のとき「ステップがありません」と表示される。

**containerURL が nil になる主な要因**:

1. **App Group が Developer Portal に未登録**
   - `group.` プレフィックス付きの ID は Developer Portal での登録が必須
   - 未登録だと `containerURL(forSecurityApplicationGroupIdentifier:)` が nil を返す

2. **ウィジェット拡張の entitlements がビルドに反映されていない**
   - `project.yml` の `CODE_SIGN_ENTITLEMENTS` が正しく適用されているか
   - Xcode で生成されたプロジェクトで Signing & Capabilities を確認

3. **シミュレータの制限**
   - シミュレータでは App Group の `containerURL` が nil になることがある（既知の制限）
   - 実機での動作確認が必要

### 原因 B: アプリとウィジェットが別ストアを参照

**根拠**: `BabyStepsApp.swift` では `appGroupContainer` が nil のとき `legacyURL`（Application Support）を使用する。

| 状況 | アプリのストア | ウィジェットのストア |
| --- | --- | --- |
| 両方 App Group 取得成功 | App Group | App Group（同一） |
| アプリのみ成功 | App Group | nil → 空表示 |
| アプリ失敗・ウィジェット失敗 | Application Support | nil → 空表示 |

アプリが App Group を使えている一方で、ウィジェットだけ `containerURL` が nil の場合、この不整合が発生する。

### 原因 C: ストアパスの不一致

**現状のパス**:

- アプリ: `appGroupContainer.appendingPathComponent("default.store")`
- ウィジェット: `containerURL.appendingPathComponent("default.store")`

両方とも `default.store` を使用しており、コード上は一致している。

### 原因 D: 移行ロジックの影響

**根拠**: `migrateStoreIfNeeded` は `legacyExists && !targetExists` のときのみ実行される。

- 再インストール後は `legacyExists == false` のため移行は実行されない
- 新規インストールと同様に、App Group 内に新規ストアが作成される想定
- 移行ロジックが直接の原因である可能性は低い

---

## 3. 確認すべき項目

### 3.1 Developer Portal

- [ ] App Groups で `group.com.yu1Ro5.BabySteps` が作成されているか
- [ ] 該当 App Group に App ID `com.yu1Ro5.BabySteps` と `com.yu1Ro5.BabySteps.BabyStepsWidget` が紐づいているか

### 3.2 Xcode（xcodegen generate 後）

- [ ] BabySteps ターゲット: Signing & Capabilities に App Groups が表示されているか
- [ ] BabyStepsWidget ターゲット: 同様に App Groups が表示されているか
- [ ] 両方で `group.com.yu1Ro5.BabySteps` が選択されているか

### 3.3 実行環境

- [ ] 実機で再現するか（シミュレータは App Group が不安定な場合あり）
- [ ] アプリを一度削除してから再インストールしているか

---

## 4. 推奨対策

### 対策 1: App Group の登録確認（最優先）

1. [Apple Developer Portal](https://developer.apple.com/account) → Identifiers → App Groups
2. `group.com.yu1Ro5.BabySteps` が存在するか確認
3. なければ作成し、App ID の両方（メインアプリ・ウィジェット）に割り当て

### 対策 2: デバッグ用の App Group 検証

App Group が有効かどうかを確認するため、`UserDefaults(suiteName:)` で簡単な値の共有を試す。  
`UserDefaults` は `containerURL` が nil でも動作することがあるため、App Group の有効性を切り分ける参考になる。

### 対策 3: SwiftData の自動検出に委譲（オプション）

`ModelConfiguration` に URL を渡さず、SwiftData に App Group の自動検出を任せる方法がある。  
ただし既存の明示的 URL 指定との整合性に注意が必要。

---

## 5. 実装した対策（UserDefaults フォールバック）

`containerURL` が nil でも `UserDefaults(suiteName:)` は動作することがあるため、以下のフォールバックを追加した。

- **WidgetDataSync**: App Group の UserDefaults に進捗データを読み書き
- **アプリ側**: データ保存時および起動時に `WidgetDataSync.writeToUserDefaults` を呼ぶ
- **ウィジェット側**: SwiftData が使えない場合、`WidgetDataSync.readFromUserDefaults` で表示

これにより、`containerURL` が nil でも UserDefaults が使える環境ではウィジェットにデータが表示される。

## 6. 次のアクション

1. **Developer Portal で App Group の登録を確認・修正**
2. **実機で再現するか確認**
3. 上記フォールバックで改善するか確認
