# 📱 App Store Screenshots Generation

このドキュメントでは、BabyStepsアプリのApp Store Connect審査用スクリーンショットを自動生成する方法を説明します。

## 🎯 必要なスクリーンショット

App Store Connectの審査では、以下のデバイスサイズのスクリーンショットが必要です：

- **📱 iPhone (6.5 inch)**: iPhone 15 Pro Max相当
- **📱 iPad (13 inch)**: iPad Pro (13-inch) (6th generation)

## 🚀 スクリーンショット生成方法

### 1. GitHub Actionsワークフローの実行

1. GitHubリポジトリの **Actions** タブに移動
2. **Generate App Store Screenshots** ワークフローを選択
3. **Run workflow** ボタンをクリック
4. デバイスタイプを選択：
   - `both`: iPhoneとiPad両方のスクリーンショットを生成
   - `iphone`: iPhoneのみ
   - `ipad`: iPadのみ
5. **Run workflow** をクリックして実行開始

### 2. ワークフローの実行内容

ワークフローは以下の手順でスクリーンショットを生成します：

1. **環境セットアップ**
   - macOS環境での実行
   - Xcode 16.4のセットアップ
   - XcodeGenのインストール

2. **プロジェクト生成**
   - `xcodegen generate` でXcodeプロジェクトを生成

3. **アプリビルド**
   - iOSシミュレーター用にアプリをビルド

4. **スクリーンショット撮影**
   - 各デバイスでアプリを起動
   - 5つの主要画面を撮影：
     - メイン画面（タスク一覧）
     - タスクリスト
     - タスク追加画面
     - タスク詳細画面
     - 進捗表示画面

5. **成果物の保存**
   - スクリーンショットをGitHub Artifactsとして保存
   - 30日間保持

## 📸 生成されるスクリーンショット

### iPhone (6.5 inch)
- `01-main-screen.png` - メイン画面
- `02-task-list.png` - タスクリスト
- `03-add-task.png` - タスク追加
- `04-task-detail.png` - タスク詳細
- `05-progress-view.png` - 進捗表示

### iPad (13 inch)
- `01-main-screen.png` - メイン画面
- `02-task-list.png` - タスクリスト
- `03-add-task.png` - タスク追加
- `04-task-detail.png` - タスク詳細
- `05-progress-view.png` - 進捗表示

## 📥 スクリーンショットのダウンロード

1. ワークフロー実行完了後、**Actions** タブで実行結果を確認
2. **Artifacts** セクションから `app-store-screenshots` をダウンロード
3. ダウンロードしたZIPファイルを解凍
4. `screenshots/iphone/` と `screenshots/ipad/` フォルダ内の画像を使用

## 🔧 トラブルシューティング

### よくある問題

1. **シミュレーターが起動しない**
   - ワークフローを再実行
   - より長い待機時間を設定

2. **スクリーンショットが空**
   - アプリの起動時間を延長
   - シミュレーターの状態を確認

3. **ビルドエラー**
   - XcodeGenの設定を確認
   - 依存関係の問題を解決

### 手動でのスクリーンショット生成

GitHub Actionsが使用できない場合：

```bash
# ローカル環境でスクリーンショット生成
xcodegen generate
xcodebuild -project BabySteps.xcodeproj -scheme BabySteps -destination 'platform=iOS Simulator,name=iPhone 15 Pro Max,OS=18.0' build

# シミュレーターでスクリーンショット撮影
xcrun simctl io booted screenshot screenshot.png
```

## 📋 App Store Connectでの使用方法

1. **App Store Connect** にログイン
2. **BabySteps** アプリを選択
3. **App Store** → **スクリーンショット** セクション
4. 各デバイスサイズに適切なスクリーンショットをアップロード：
   - iPhone (6.5 inch): `screenshots/iphone/` 内の画像
   - iPad (13 inch): `screenshots/ipad/` 内の画像

## 🎨 スクリーンショットの最適化

- **高品質**: 高解像度で撮影
- **一貫性**: 同じアプリ状態で撮影
- **可読性**: テキストとUI要素が明確に表示
- **魅力的**: アプリの主要機能を効果的にアピール

## 📞 サポート

スクリーンショット生成で問題が発生した場合：

1. GitHub Actionsの実行ログを確認
2. エラーメッセージを確認
3. 必要に応じてワークフローを再実行

---

**注意**: このワークフローは、App Store Connectの審査要件を満たすスクリーンショットを生成することを目的としています。生成されたスクリーンショットは、アプリの実際の機能と一致していることを確認してください。