# GitHub Actions iOS 自動ビルド・TestFlight配布 設定ガイド

## 概要
このワークフローは、iOSアプリの自動ビルドとTestFlightへの配布を自動化します。

## ワークフローの種類

### 1. 基本版 (`ios-build-testflight.yml`)
- 日時ベースのバージョン番号
- シンプルな自動化

### 2. セマンティックバージョニング版 (`ios-build-testflight-semver.yml`) ⭐ **推奨**
- セマンティックバージョニング対応
- 手動バージョン管理
- 自動Gitタグ作成
- GitHub Release自動作成

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

### 3. ExportOptions.plist の設定 ✅ **完了**
チームID `58Y7Q3D4A7` が設定済みです。

### 4. プロジェクト設定の確認
- `project.yml`ファイルが正しく設定されていることを確認
- スキーム名が`BabySteps`になっていることを確認
- コード署名の設定が正しいことを確認

## セマンティックバージョニング版の特徴

### バージョン管理
- **Major**: 破壊的変更（例：1.0.0 → 2.0.0）
- **Minor**: 新機能追加（例：1.0.0 → 1.1.0）
- **Patch**: バグ修正（例：1.0.0 → 1.0.1）
- **Custom**: カスタムバージョン指定

### 手動トリガー
GitHub Actionsタブから以下の選択肢で実行可能：
- バージョンタイプ選択（major/minor/patch/custom）
- カスタムバージョン指定

### 自動化機能
1. バージョン番号の自動計算
2. Info.plistの自動更新
3. Gitタグの自動作成
4. GitHub Releaseの自動作成
5. TestFlightへの自動アップロード

## ワークフローの動作

### トリガー条件
- `main`ブランチへのプッシュ
- `develop`ブランチへのプッシュ
- 手動トリガー（workflow_dispatch）

### 実行される処理
1. コードのチェックアウト
2. XcodeGenによるプロジェクト生成
3. 現在のバージョン取得
4. 新しいバージョン計算
5. Info.plistの更新
6. Gitタグとコミットの作成
7. リリースビルドの作成
8. IPAファイルのエクスポート
9. TestFlightへのアップロード
10. ビルド成果物の保存
11. GitHub Releaseの作成

### バージョン番号形式
- **バージョン**: セマンティック（例：1.2.3）
- **ビルド番号**: 日時ベース（例：2412151430）

## トラブルシューティング

### よくある問題
1. **コード署名エラー**: 証明書とプロビジョニングプロファイルの設定を確認
2. **API Key認証エラー**: App Store Connect API Keyの権限と有効性を確認
3. **ビルドエラー**: XcodeGenの設定とスキーム名を確認
4. **Git権限エラー**: ワークフローに適切なGit権限があることを確認

### ログの確認
GitHub Actionsの実行ログで詳細なエラー情報を確認できます。

## 注意事項
- セマンティックバージョニング版は、Gitタグとリリースを自動作成します
- ワークフローには適切なGit権限が必要です
- ビルド成果物は30日間保存されます
- 手動トリガーはGitHubのActionsタブから実行可能です
- チームID `58Y7Q3D4A7` が設定済みです