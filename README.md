# BabySteps

SwiftUIとSwiftDataを使用したモダンなiOSタスク管理アプリケーションです。タスクを小さなステップに分解して、段階的に目標を達成できるように設計されています。GitHubライクなアクティビティグラフで日々の進捗を可視化し、モチベーションを維持できます。

## 特徴

- 🚀 **SwiftUIベース**: モダンなSwiftUIフレームワークを使用
- 💾 **SwiftData対応**: iOS 17+の新しいデータ永続化フレームワーク
- 📱 **iOS 18.0+対応**: 最新のiOS機能をサポート
- 🎯 **タスク管理**: タスクを小さなステップに分解して管理
- 📊 **進捗追跡**: 全体と個別の進捗率を視覚的に表示
- 📈 **アクティビティグラフ**: GitHubライクな日別アクティビティ表示
- 🔄 **CI/CD対応**: GitHub Actionsで自動ビルド・テスト・TestFlight配布
- 🧪 **テスト対応**: ユニットテストの実行環境
- 🎨 **モダンUI**: タブベースの直感的なインターフェース

## アプリ機能

### メイン機能

- **タスク作成**: 新しいタスクを簡単に作成
- **ステップ管理**: 各タスクを小さなステップに分解（デフォルト5個、調整可能）
- **進捗追跡**: 完了したステップの割合を表示
- **全体進捗**: 全タスクの総合的な進捗率を表示
- **データ永続化**: SwiftDataによる自動的なデータ保存
- **アクティビティ表示**: 日別のステップ完了数をカレンダー形式で表示

### 画面構成

- **タスクタブ**: タスク一覧と全体進捗の表示
- **アクティビティタブ**: GitHubライクなアクティビティグラフ
- **タスク追加**: 新しいタスクを作成するモーダル（ステップ数調整可能）
- **ステップ追加**: 既存タスクにステップを追加するモーダル
- **タスク詳細**: 各タスクのステップ一覧と進捗表示

## プロジェクト構造

```text
BabySteps/
├── .github/workflows/     # GitHub Actions設定
│   ├── ios-build.yml              # ビルド・テストワークフロー
│   ├── ios-build-testflight.yml   # TestFlight配布ワークフロー
│   ├── markdownlint.yml           # Markdown品質チェック
│   └── format-patch.yml           # コードフォーマット
├── Sources/               # ソースコード
│   ├── App/              # アプリケーションコード
│   │   └── BabyStepsApp.swift      # メインアプリ（タブビュー、SwiftData設定）
│   ├── Models/           # データモデル
│   │   ├── Task.swift              # Taskモデル
│   │   ├── TaskStep.swift          # TaskStepモデル
│   │   ├── Activity.swift          # アクティビティ関連モデル
│   │   └── ActivityLevel.swift     # アクティビティレベル定義
│   ├── Views/            # SwiftUIビュー
│   │   ├── TaskListView.swift      # メインタスク画面
│   │   └── Activity/               # アクティビティ関連ビュー
│   │       ├── ActivityView.swift      # アクティビティメイン画面
│   │       ├── CalendarGridView.swift  # カレンダーグリッド
│   │       └── DayDetailView.swift     # 日別詳細表示
│   ├── ViewModels/       # ビューモデル
│   │   ├── TaskViewModel.swift         # タスク管理ロジック
│   │   └── ActivityViewModel.swift     # アクティビティ管理ロジック
│   ├── Assets.xcassets/  # アセット
│   ├── Info.plist        # アプリ情報
│   └── PrivacyInfo.xcprivacy      # プライバシー情報
├── Tests/                 # テストコード
├── project.yml           # XcodeGen設定
├── .swift-format         # Swiftコードフォーマット設定
├── .markdownlint.json    # Markdown品質チェック設定
└── README.md             # このファイル
```

## データモデル

### Task

- タスクの基本情報（ID、タイトル、作成日時）
- ステップの配列
- 進捗率の計算機能
- ステップの追加・削除機能

### TaskStep

- ステップの基本情報（ID、完了状態、順序、完了日時）
- 完了状態の切り替え機能
- 親タスクとの関連
- 完了日時の自動記録

### Activity

- 日別アクティビティ情報
- ステップ完了数の追跡
- アクティビティレベルの計算

### ActivityLevel

- アクティビティレベル（none, low, medium, high, veryHigh）
- 各レベルに対応するカラー定義
- 完了数に基づく自動判定

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

### コードフォーマット

このリポジトリでは、Swiftコードの一貫性を保つためにswift-formatを使用しています。

#### ローカルでの実行

Swiftファイルをローカルでフォーマットするには：

```bash
swift format --in-place Sources/**/*.swift
```

#### 設定ファイル

swift-formatの設定は `.swift-format` ファイルでカスタマイズできます。

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

- **ビルド・テスト**: iOSアプリのビルドとテスト実行
- **TestFlight配布**: 自動署名によるTestFlightアップロード
- **Markdown Lint**: Markdownファイルのフォーマットチェック
- **コードフォーマット**: Swiftコードの自動フォーマット

### 手動実行

GitHubのActionsタブから手動でワークフローを実行できます。

### TestFlight配布

`ios-build-testflight.yml` ワークフローを使用してTestFlightに自動配布できます。

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
- **Marketing Version**: 0.0.2
- **Build Version**: 1

## 最近の更新履歴

### v0.0.2 (最新)

- 🎯 **タスク管理の改善**: 調整可能なチェックボックスカウンター（デフォルト5個）
- 📊 **アクティビティ機能**: GitHubライクな日別アクティビティグラフ
- 🎨 **UI/UX改善**: タブベースのインターフェース、カレンダー表示
- 🔧 **バグ修正**: アクティビティタブのグラフ色表示問題を修正
- 📱 **パフォーマンス向上**: アクティビティ計算の最適化

### v0.0.1

- 🚀 **初期リリース**: 基本的なタスク管理機能
- 💾 **SwiftData統合**: データ永続化の実装
- 🔄 **CI/CD設定**: GitHub Actionsワークフローの設定

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

5. **アクティビティ表示の問題**
   - 完了済みステップのcompletedAtが正しく設定されているか確認
   - データベースの整合性をチェック

## 貢献

1. このリポジトリをフォーク
2. フィーチャーブランチを作成
3. 変更をコミット
4. プルリクエストを作成

### 開発ガイドライン

- SwiftUIのベストプラクティスに従う
- SwiftDataの適切な使用方法を守る
- アクセシビリティを考慮したUI設計
- パフォーマンスを意識した実装

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。
