# BabySteps - MVVM Architecture Documentation

## 概要

BabyStepsは、SwiftUI + SwiftData + MVVMパターンを使用したiOSアプリケーションです。画像のコンセプト「タスクのステップ分解と進捗可視化」を実現するため、タスクを小さなステップに分解し、各ステップの完了ごとに進捗を可視化する機能を提供します。

## アーキテクチャ概要

### MVVMパターンの採用理由

1. **SwiftUIとの親和性**: `@Observable`と`@State`によるデータバインディング
2. **テスト容易性**: ViewModelのビジネスロジックを独立してテスト可能
3. **保守性**: 責務の明確な分離による保守性の向上
4. **拡張性**: 新機能追加時の影響範囲を最小限に抑制

### SwiftDataの採用理由

1. **iOS 18.0+対応**: 最新のデータ永続化フレームワーク
2. **SwiftUI統合**: `@Query`によるリアクティブなデータ取得
3. **パフォーマンス**: 効率的なデータアクセスとメモリ管理
4. **型安全性**: コンパイル時の型チェック

## ファイル構成と責務

### 1. Task.swift (Model)

#### 責務
- タスクとステップのデータ構造定義
- SwiftDataモデルの永続化設定
- 進捗計算ロジック

#### 主要なプロパティ
```swift
@Model
final class Task {
    var id: UUID           // 一意識別子
    var title: String      // タスクタイトル
    var createdAt: Date    // 作成日時
    var steps: [TaskStep]  // ステップ配列
}
```

#### 進捗計算ロジック
```swift
var progress: Double {
    guard !steps.isEmpty else { return 0.0 }
    let completedSteps = steps.filter { $0.isCompleted }.count
    return Double(completedSteps) / Double(steps.count)
}
```

#### 設計思想
- **単一責任原則**: データ構造と進捗計算のみを担当
- **不変性**: `@Model`によるSwiftDataとの自動同期
- **計算プロパティ**: 進捗率をリアルタイムで計算

### 2. TaskViewModel.swift (ViewModel)

#### 責務
- タスク管理のビジネスロジック
- SwiftDataとのデータ操作
- View層へのデータ提供

#### 主要な機能
1. **Task Management**
   - タスクの作成・削除・更新
   - ステップの追加・削除・完了状態管理

2. **Data Queries**
   - 全タスク取得
   - 完了済みタスク取得
   - 進行中タスク取得

3. **Progress Management**
   - 個別タスクの進捗取得
   - 全体進捗率の計算

#### SwiftData連携
```swift
// データの挿入
func createTask(title: String) -> Task {
    let task = Task(title: title)
    modelContext.insert(task)
    return task
}

// データの保存
try? modelContext.save()
```

#### 設計思想
- **依存性注入**: ModelContextを外部から注入
- **エラーハンドリング**: try-catchによる安全なデータ操作
- **トランザクション管理**: 一連の操作をまとめて保存

### 3. TaskListView.swift (View)

#### 責務
- ユーザーインターフェースの表示
- ユーザー操作の受け取り
- ViewModelとのデータバインディング

#### 主要なUIコンポーネント
1. **Overall Progress View**
   - 全体進捗率の表示
   - プログレスバーとパーセンテージ

2. **Task List**
   - タスク一覧の表示
   - 各タスクの進捗表示

3. **Task Row View**
   - 個別タスクの詳細表示
   - ステップごとのチェックボックス

#### SwiftUI + SwiftData連携
```swift
@Environment(\.modelContext) private var modelContext
@State private var viewModel: TaskViewModel

.onAppear {
    viewModel = TaskViewModel(modelContext: modelContext)
}
```

#### 設計思想
- **宣言的UI**: SwiftUIによる直感的なUI定義
- **状態管理**: `@State`によるローカル状態管理
- **コンポーネント化**: 再利用可能なUIコンポーネント

## データフロー

### 1. タスク作成フロー
```
User Input → TaskListView → TaskViewModel → Task Model → SwiftData
```

### 2. ステップ完了フロー
```
User Tap → TaskRowView → TaskViewModel → TaskStep Model → SwiftData → UI Update
```

### 3. 進捗更新フロー
```
Data Change → SwiftData → @Observable → SwiftUI → UI Update
```

## 依存関係

### 依存関係図
```
TaskListView (View)
    ↓
TaskViewModel (ViewModel)
    ↓
Task, TaskStep (Model)
    ↓
SwiftData (Persistence)
```

### 依存性の方向
- **View → ViewModel**: ViewModelのメソッドを呼び出し
- **ViewModel → Model**: モデルのプロパティにアクセス
- **Model → SwiftData**: `@Model`による自動永続化

## 拡張性の考慮

### 1. 新機能追加時の影響範囲
- **新画面追加**: 新しいViewファイルのみ作成
- **新機能追加**: ViewModelにメソッド追加
- **データ構造変更**: Modelファイルのみ修正

### 2. 将来的な拡張案
- **カテゴリ機能**: Taskモデルにcategoryプロパティ追加
- **期限管理**: TaskモデルにdueDateプロパティ追加
- **通知機能**: NotificationServiceの追加
- **統計機能**: AnalyticsServiceの追加

## テスト戦略

### 1. ViewModelテスト
- ビジネスロジックの単体テスト
- SwiftData操作のモック化
- エラーハンドリングのテスト

### 2. Modelテスト
- 進捗計算ロジックのテスト
- データ整合性のテスト

### 3. UIテスト
- ユーザー操作の統合テスト
- 画面遷移のテスト

## パフォーマンス考慮事項

### 1. SwiftData最適化
- 必要なデータのみをフェッチ
- バッチ処理による一括更新
- インデックスの適切な設定

### 2. SwiftUI最適化
- 不要な再描画の防止
- 効率的なリスト表示
- メモリリークの防止

## セキュリティ考慮事項

### 1. データ検証
- 入力値のサニタイゼーション
- データ整合性のチェック

### 2. アクセス制御
- 適切なスコープ設定
- 機密データの保護

## まとめ

BabyStepsのMVVMアーキテクチャは、SwiftUIとSwiftDataの最新機能を活用し、保守性・拡張性・テスト容易性を重視した設計となっています。画像のコンセプト「タスクのステップ分解と進捗可視化」を効果的に実現し、ユーザーが継続的にタスクに取り組めるアプリケーションを提供します。

### 主要な利点
1. **明確な責務分離**: 各レイヤーの役割が明確
2. **リアクティブなUI**: SwiftUIによる自動UI更新
3. **効率的なデータ管理**: SwiftDataによる最適化された永続化
4. **将来性**: iOS 18.0+の最新機能を活用