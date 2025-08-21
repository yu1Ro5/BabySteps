# BabySteps

SwiftUIとSwiftDataを使用したモダンなiOSタスク管理アプリケーションです。タスクを小さなステップに分解して、段階的に目標を達成できるように設計されています。

## 特徴

- 🚀 **SwiftUIベース**: モダンなSwiftUIフレームワークを使用
- 💾 **SwiftData対応**: iOS 17+の新しいデータ永続化フレームワーク
- 📱 **iOS 18.0+対応**: 最新のiOS機能をサポート
- 🎯 **タスク管理**: タスクを小さなステップに分解して管理
- 📊 **進捗追跡**: 全体と個別の進捗率を視覚的に表示
- 🔄 **CI/CD対応**: GitHub Actionsで自動ビルド・テスト
- 🧪 **テスト対応**: ユニットテストの実行環境

## アプリ機能

### メイン機能

- **タスク作成**: 新しいタスクを簡単に作成
- **ステップ管理**: 各タスクを小さなステップに分解
- **進捗追跡**: 完了したステップの割合を表示
- **全体進捗**: 全タスクの総合的な進捗率を表示
- **データ永続化**: SwiftDataによる自動的なデータ保存

### 画面構成

- **メイン画面**: タスク一覧と全体進捗の表示
- **タスク追加**: 新しいタスクを作成するモーダル
- **ステップ追加**: 既存タスクにステップを追加するモーダル
- **タスク詳細**: 各タスクのステップ一覧と進捗表示

## プロジェクト構造

```text
BabySteps/
├── .github/workflows/     # GitHub Actions設定
├── Sources/               # ソースコード
│   ├── App/              # アプリケーションコード
│   │   └── BabyStepsApp.swift      # メインアプリ（SwiftData設定）
│   ├── Models/           # データモデル
│   │   └── Task.swift    # TaskとTaskStepモデル
│   ├── Views/            # SwiftUIビュー
│   │   └── TaskListView.swift      # メイン画面
│   ├── ViewModels/       # ビューモデル
│   │   └── TaskViewModel.swift     # タスク管理ロジック
│   ├── Assets.xcassets/  # アセット
│   ├── Info.plist        # アプリ情報
│   └── PrivacyInfo.xcprivacy      # プライバシー情報
├── Tests/                 # テストコード
├── project.yml           # XcodeGen設定
└── README.md             # このファイル
```

## データモデル

### Task

- タスクの基本情報（ID、タイトル、作成日時）
- ステップの配列
- 進捗率の計算機能
- ステップの追加・削除機能

### TaskStep

- ステップの基本情報（ID、タイトル、完了状態、順序）
- 完了状態の切り替え機能
- 親タスクとの関連

## セットアップ

### 前提条件

- macOS環境（Xcode 15.0以上）
- iOS 18.0+対応
- XcodeGen
- Homebrew

### 1. XcodeGenのインストール

```bash
brew install xcodegen
```

### 2. プロジェクトの生成

```bash
xcodegen generate
```

### 3. Xcodeで開く

```bash
open BabySteps.xcodeproj
```

## 開発

### 新しいファイルの追加

1. 適切なディレクトリ（Models、Views、ViewModels）にSwiftUIファイルを追加
2. `project.yml` の `sources` セクションにパスを追加
3. `xcodegen generate` を実行

### SwiftUIビューの追加

新しい画面を追加する場合：

1. `Sources/Views/` に新しいViewファイルを作成
2. 必要に応じてViewModelを作成
3. データモデルの更新が必要な場合はModelsディレクトリに追加

### 依存関係の追加

`project.yml` の `dependencies` セクションに追加：

```yaml
dependencies:
  - sdk: Foundation.framework
  - package: Alamofire
```

### Markdown Lint

このリポジトリでは、Markdownファイル（`.md`と`.mdc`）の一貫性を保つためにmarkdownlintを使用しています。

#### ローカルでの実行

Markdownファイルをローカルでチェックするには：

```bash
npm install -g markdownlint-cli
markdownlint '**/*.md' '**/*.mdc'
```

#### 設定ファイル

markdownlintの設定は `.markdownlint.json` ファイルでカスタマイズできます。現在の設定：

- `default: true`: デフォルトルールを有効化
- `MD013: false`: 行の長さ制限を無効化
- `MD033: false`: HTMLタグの使用を許可

## CI/CD

### GitHub Actions

このプロジェクトは以下のワークフローを提供します：

- **ビルド**: iOSアプリのビルド
- **テスト**: ユニットテストの実行
- **アーカイブ**: リリース用アーカイブの作成
- **Markdown Lint**: Markdownファイル（`.md`と`.mdc`）のフォーマットチェック

### 手動実行

GitHubのActionsタブから手動でワークフローを実行できます。

## ビルド設定

### ターゲット

- **BabySteps**: メインアプリケーション
- **BabyStepsTests**: ユニットテスト

### 設定

- **iOS Deployment Target**: 18.0
- **Bundle Identifier**: com.yu1Ro5.BabySteps
- **Code Signing**: Automatic
- **Framework**: SwiftUI + SwiftData
- **Xcode Version**: 16.4

## トラブルシューティング

### よくある問題

1. **XcodeGenが見つからない**

   ```bash
   brew install xcodegen
   ```

2. **プロジェクトの生成に失敗**

   ```bash
   xcodegen --spec project.yml
   ```

3. **ビルドエラー**
   - Xcodeのバージョンを確認（16.4以上推奨）
   - iOS 18.0+のシミュレーターを使用
   - 依存関係の設定を確認

4. **SwiftData関連のエラー**
   - iOS 17.0+のデプロイメントターゲットを確認
   - ModelContainerの設定を確認

## 貢献

1. このリポジトリをフォーク
2. フィーチャーブランチを作成
3. 変更をコミット
4. プルリクエストを作成
