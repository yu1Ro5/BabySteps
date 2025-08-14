# BabySteps

Xcodeを使わずに作成されたiOSアプリケーションです。XcodeGenを使用してプロジェクトファイルを生成し、GitHub ActionsでmacOSランナー上でビルド・テストを実行します。

## 特徴

- 🚀 **Xcode不要**: XcodeGenでプロジェクトファイルを自動生成
- 🔄 **CI/CD対応**: GitHub Actionsで自動ビルド・テスト
- 📱 **iOS 14.0+対応**: 最新のiOS機能をサポート
- 🧪 **テスト対応**: ユニットテストの実行環境

## プロジェクト構造

```
BabySteps/
├── .github/workflows/     # GitHub Actions設定
├── Sources/               # ソースコード
│   ├── App/              # アプリケーションコード
│   ├── Info.plist        # アプリ情報
│   ├── Main.storyboard   # メイン画面
│   └── LaunchScreen.storyboard # 起動画面
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

1. `Sources/` ディレクトリにSwiftファイルを追加
2. `project.yml` の `sources` セクションにパスを追加
3. `xcodegen generate` を実行

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

## ビルド設定

### ターゲット

- **BabySteps**: メインアプリケーション
- **BabyStepsTests**: ユニットテスト

### 設定

- **iOS Deployment Target**: 14.0
- **Bundle Identifier**: com.yu1Ro5.BabySteps
- **Code Signing**: Automatic

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

