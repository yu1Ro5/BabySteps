# BabySteps

SwiftUIベースのiOSアプリケーションです。XcodeGenを使用してプロジェクトファイルを生成し、GitHub ActionsでmacOSランナー上でビルド・テストを実行します。

## 特徴

- 🚀 **SwiftUIベース**: モダンなSwiftUIフレームワークを使用
- 🔄 **CI/CD対応**: GitHub Actionsで自動ビルド・テスト
- 📱 **iOS 18.0+対応**: 最新のiOS機能をサポート
- 🧪 **テスト対応**: ユニットテストとUIテストの実行環境
- 📸 **スクリーンショットテスト**: PR上でUIの確認が可能

## プロジェクト構造

```
BabySteps/
├── .github/workflows/     # GitHub Actions設定
├── Sources/               # ソースコード
│   ├── App/              # アプリケーションコード
│   │   ├── BabyStepsApp.swift      # メインアプリ
│   │   └── ContentView.swift       # メイン画面（ToDo管理）
│   └── Info.plist        # アプリ情報
├── Tests/                 # ユニットテストコード
├── UITests/               # UIテストコード
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

## テスト

### ユニットテスト

基本的な機能のテストを実行：

```bash
xcodebuild test -scheme BabySteps -destination 'platform=iOS Simulator,name=iPhone SE (3rd generation),OS=18.5'
```

### UIテスト

UIの表示とレイアウトのテストを実行：

```bash
xcodebuild test -scheme BabySteps -only-testing:BabyStepsUITests -destination 'platform=iOS Simulator,name=iPhone SE (3rd generation),OS=18.5'
```

#### UIテストの内容

- **初期画面の表示確認**: アプリ起動直後の画面要素の検証
- **テキスト内容の確認**: 「BabySteps」「Hello, iOS!」の表示確認
- **レイアウトの検証**: VStackの配置、間隔、中央揃えの確認
- **視覚要素の確認**: チェックマークアイコンのサイズと形状の検証
- **アクセシビリティ**: テキスト要素のアクセシビリティ設定の確認

## CI/CD

### GitHub Actions

このプロジェクトは以下のワークフローを提供します：

- **ビルド**: iOSアプリのビルド
- **ユニットテスト**: 基本的な機能テストの実行
- **UIテスト**: UI表示とレイアウトのテスト実行
- **スクリーンショット撮影**: 各テストケースでの画面キャプチャ
- **PRコメント**: テスト結果とスクリーンショット情報の自動投稿

### 手動実行

GitHubのActionsタブから手動でワークフローを実行できます。

### スクリーンショットの確認

PRが作成されると、自動的に以下の情報がコメントされます：

1. **UIテストスクリーンショット**: 各テストケースで撮影された画面画像
2. **テスト結果サマリー**: 実行されたテストの結果一覧
3. **アーティファクト**: スクリーンショットファイルのダウンロードリンク

#### スクリーンショットの種類

- **Initial Screen Screenshot**: アプリ起動直後の画面
- **Portrait Orientation Screenshot**: 縦向き表示の確認
- **Layout Spacing Screenshot**: レイアウト間隔の検証
- **Visual Elements Screenshot**: 視覚要素の確認
- **Text Content Screenshot**: テキスト内容の検証

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
- **BabyStepsUITests**: UIテスト

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

4. **UIテストの失敗**
   - シミュレーターのバージョンを確認
   - テストターゲットの設定を確認

## 貢献

1. このリポジトリをフォーク
2. フィーチャーブランチを作成
3. 変更をコミット
4. プルリクエストを作成

### テストの追加

新しい機能を追加する際は、対応するテストも追加してください：

- **ユニットテスト**: ビジネスロジックのテスト
- **UIテスト**: 画面表示とユーザーインタラクションのテスト
- **スクリーンショット**: 重要な画面状態のキャプチャ

