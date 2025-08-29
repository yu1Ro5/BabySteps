# App Store スクリーンショット自動生成

このドキュメントでは、GitHub Actionsを使用してApp Store審査用のスクリーンショットを自動生成する方法について説明します。

## 概要

`generate-screenshots.yml` ワークフローは、iOSシミュレータを使用して以下のスクリーンショットを自動生成します：

- **iPhone 6.5インチ**: iPhone 15 Pro Maxシミュレータ
- **iPad 13インチ**: iPad Pro (13-inch)シミュレータ

## 必要な環境

- macOS 15 ランナー
- Xcode 16.4 (16.3にフォールバック可能)
- iOS 18.5 シミュレータ (18.4, 18.3にフォールバック可能)

## ワークフローの実行方法

### 1. 手動実行 (推奨)

1. GitHubリポジトリの **Actions** タブに移動
2. **Generate App Store Screenshots** ワークフローを選択
3. **Run workflow** ボタンをクリック
4. 必要に応じてブランチを選択して実行

### 2. 自動実行

以下の条件でワークフローが自動実行されます：

- `main` または `develop` ブランチへのプッシュ
- `Sources/` ディレクトリまたは `project.yml` の変更
- プルリクエストの作成・更新

## 生成されるスクリーンショット

| デバイス | ファイル名 | サイズ | 説明 |
|---------|-----------|--------|------|
| iPhone 16 Pro Max | `iphone_6.5inch.png` | 6.5インチ | App Store用iPhoneスクリーンショット |
| iPad Pro (13-inch) | `ipad_13inch.png` | 13インチ | App Store用iPadスクリーンショット |

## 成果物のダウンロード

ワークフロー完了後、以下の方法でスクリーンショットをダウンロードできます：

1. GitHubリポジトリの **Actions** タブに移動
2. 完了したワークフローを選択
3. **Artifacts** セクションから `app-store-screenshots` をダウンロード

## 設定のカスタマイズ

### スクリーンショット設定ファイル

`screenshot-config.json` ファイルで以下の設定を変更できます：

```json
{
  "ios_version": "18.5",
  "fallback_versions": ["18.4", "18.3"],
  "devices": [...],
  "screenshot_settings": {
    "app_launch_wait_time": 8,
    "simulator_boot_wait_time": 10
  }
}
```

### 新しいデバイスの追加

新しいデバイスを追加するには、`screenshot-config.json` の `devices` 配列に以下を追加：

```json
{
  "name": "デバイス名",
  "simulator_name": "シミュレータ名",
  "display_size": "ディスプレイサイズ",
  "output_filename": "出力ファイル名.png",
  "description": "説明"
}
```

## トラブルシューティング

### よくある問題

1. **iOS 18.5シミュレータが利用できない**
   - 自動的に18.4、18.3にフォールバックされます
   - ワークフローログで使用されたバージョンを確認してください

2. **シミュレータの起動に時間がかかる**
   - `simulator_boot_wait_time` の値を増やしてください
   - 現在の設定: 10秒

3. **アプリの起動が遅い**
   - `app_launch_wait_time` の値を増やしてください
   - 現在の設定: 8秒

### ログの確認

ワークフローの実行ログで以下を確認できます：

- 使用されたXcodeバージョン
- 利用可能なiOSシミュレータ
- ビルドプロセスの詳細
- スクリーンショット生成の各ステップ

## パフォーマンス最適化

- ワークフローのタイムアウト: 30分
- 成果物の保持期間: 30日
- シミュレータの自動クリーンアップ
- 並列ビルドの最適化

## セキュリティ

- コード署名は無効化 (`CODE_SIGNING_ALLOWED=NO`)
- デバッグ設定でのビルド
- シミュレータ環境での実行

## サポート

問題が発生した場合や、新しい機能の追加が必要な場合は、以下を確認してください：

1. GitHub Actionsの実行ログ
2. シミュレータの利用可能性
3. XcodeGenプロジェクトの生成状況
4. ビルド設定の正確性