# BabySteps

SwiftUIベースのiOSアプリケーションです。赤ちゃんの成長を記録・追跡するための包括的なアプリで、XcodeGenを使用してプロジェクトファイルを生成し、GitHub ActionsでmacOSランナー上でビルド・テストを実行します。

## 特徴

- 🚀 **SwiftUIベース**: モダンなSwiftUIフレームワークを使用
- 👶 **赤ちゃんの成長記録**: マイルストーン、成長記録、思い出の管理
- 🔄 **CI/CD対応**: GitHub Actionsで自動ビルド・テスト
- 📱 **iOS 14.0+対応**: 最新のiOS機能をサポート
- 🧪 **テスト対応**: ユニットテストの実行環境

## プロジェクト構造

```
BabySteps/
├── .github/workflows/     # GitHub Actions設定
├── Sources/               # ソースコード
│   ├── App/              # アプリケーションコード
│   │   ├── BabyStepsApp.swift      # メインアプリ
│   │   ├── ContentView.swift       # メイン画面
│   │   ├── MilestoneView.swift     # マイルストーン画面
│   │   ├── GrowthView.swift        # 成長記録画面
│   │   ├── MemoriesView.swift      # 思い出画面
│   │   └── LaunchScreenView.swift  # 起動画面
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

## CI/CD

### GitHub Actions

このプロジェクトは以下のワークフローを提供します：

- **ビルド**: iOSアプリのビルド
- **テスト**: ユニットテストの実行
- **アーカイブ**: リリース用アーカイブの作成

### 手動実行

GitHubのActionsタブから手動でワークフローを実行できます。

## アプリ機能

### メイン機能

- **マイルストーン管理**: 赤ちゃんの成長の節目を記録・管理
- **成長記録**: 体重、身長、頭囲の記録とグラフ表示
- **思い出の記録**: カテゴリ別の思い出の保存・管理
- **モダンなUI**: SwiftUIによる美しく直感的なインターフェース

### 画面構成

- **ホーム画面**: 各機能へのナビゲーション
- **マイルストーン画面**: 成長の節目の一覧と完了管理
- **成長記録画面**: 身体測定データの記録とグラフ表示
- **思い出画面**: カテゴリ別の思い出の管理

## ビルド設定

### ターゲット

- **BabySteps**: メインアプリケーション
- **BabyStepsTests**: ユニットテスト

### 設定

- **iOS Deployment Target**: 14.0
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

