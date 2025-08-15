# GitHub Actions iOS 自動ビルド・TestFlight配布 設定ガイド

## 概要
このワークフローは、iOSアプリの自動ビルドとTestFlightへの配布を自動化します。

## 必要な設定

### 1. GitHub Secrets の設定
以下のシークレットをGitHubリポジトリのSettings > Secrets and variables > Actions で設定してください：

- `APP_STORE_CONNECT_KEY_ID`: App Store Connect API Key ID
- `APP_STORE_CONNECT_ISSUER_ID`: App Store Connect Issuer ID  
- `APP_STORE_CONNECT_API_KEY`: App Store Connect API Key (Base64エンコードされた.p8ファイルの内容)

### 2. App Store Connect API Key の取得手順
1. [App Store Connect](https://appstoreconnect.apple.com/) にログイン
2. Users and Access > Keys に移動
3. Generate API Key をクリック
4. キー名を入力し、Admin権限を付与
5. 生成されたキーID、Issuer ID、API Keyをコピー

### 3. ExportOptions.plist の設定
`ExportOptions.plist`ファイル内の`YOUR_TEAM_ID`を実際のTeam IDに置き換えてください。

Team IDは以下で確認できます：
- Xcode > Preferences > Accounts > Team ID
- または Apple Developer アカウントのMembership ページ

### 4. プロジェクト設定の確認
- `project.yml`ファイルが正しく設定されていることを確認
- スキーム名が`BabySteps`になっていることを確認
- コード署名の設定が正しいことを確認

## ワークフローの動作

### トリガー条件
- `main`ブランチへのプッシュ
- 手動トリガー（workflow_dispatch）

### 実行される処理
1. コードのチェックアウト
2. XcodeGenによるプロジェクト生成
3. バージョン番号の自動更新（日時ベース）
4. リリースビルドの作成
5. IPAファイルのエクスポート
6. TestFlightへのアップロード
7. ビルド成果物の保存

### バージョン番号形式
- 形式: `YY.MM.DD.HHMM`
- 例: `24.01.15.1430` (2024年1月15日14時30分)

## トラブルシューティング

### よくある問題
1. **コード署名エラー**: 証明書とプロビジョニングプロファイルの設定を確認
2. **API Key認証エラー**: App Store Connect API Keyの権限と有効性を確認
3. **ビルドエラー**: XcodeGenの設定とスキーム名を確認

### ログの確認
GitHub Actionsの実行ログで詳細なエラー情報を確認できます。

## 注意事項
- このワークフローはApp Store配布用の設定です
- コード署名は自動設定を使用しています
- ビルド成果物は30日間保存されます
- 手動トリガーはGitHubのActionsタブから実行可能です