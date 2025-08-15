# BabySteps

SwiftUIベースのiOSアプリケーションです。XcodeGenを使用してプロジェクトファイルを生成し、GitHub ActionsでmacOSランナー上でビルド・テストを実行します。

## 特徴

- 🚀 **SwiftUIベース**: モダンなSwiftUIフレームワークを使用
- 🔄 **CI/CD対応**: GitHub Actionsで自動ビルド・テスト
- 📱 **iOS 18.0+対応**: 最新のiOS機能をサポート
- 🧪 **テスト対応**: ユニットテストの実行環境

## プロジェクト構造

```text
BabySteps/
├── .github/workflows/     # GitHub Actions設定
├── Sources/               # ソースコード
│   ├── App/              # アプリケーションコード
│   │   ├── BabyStepsApp.swift      # メインアプリ
│   │   └── ContentView.swift       # メイン画面（ToDo管理）
│   └── Info.plist        # アプリ情報
├── Tests/                 # テストコード
├── Resources/             # リソースファイル
├── project.yml           # XcodeGen設定
└── README.md             # このファイル
```

## セットアップ

### 前提条件

- macOS環境（Xcode 15.0以上）
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

1. `Sources/App/` ディレクトリにSwiftUIファイルを追加
2. `project.yml` の `sources` セクションにパスを追加
3. `xcodegen generate` を実行

### SwiftUIビューの追加

新しい画面を追加する場合：

1. `Sources/App/` に新しいViewファイルを作成
2. `ContentView.swift` にNavigationLinkを追加
3. 必要に応じてデータモデルを作成

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

## アプリ機能

### メイン機能

- **シンプルな表示**: Hello Worldの基本的な表示
- **モダンなUI**: SwiftUIによる美しく直感的なインターフェース

### 画面構成

- **メイン画面**: 基本的なHello World表示
- **シンプルなレイアウト**: アイコン、タイトル、メッセージの表示

## ビルド設定

### ターゲット

- **BabySteps**: メインアプリケーション
- **BabyStepsTests**: ユニットテスト

### 設定

- **iOS Deployment Target**: 18.0
- **Bundle Identifier**: com.yu1Ro5.BabySteps
- **Code Signing**: Automatic
- **Framework**: SwiftUI

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
   - Xcodeのバージョンを確認
   - 依存関係の設定を確認

## 貢献

1. このリポジトリをフォーク
2. フィーチャーブランチを作成
3. 変更をコミット
4. プルリクエストを作成
