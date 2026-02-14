# MainView 採用方針：具体的なコード変更案

## 方針A：MainView を削除して App に統合

**メリット**: ファイル1つ削減、構成がシンプル  
**デメリット**: App に UI が混入、将来の拡張で肥大化しやすい

### 1. BabyStepsApp.swift の変更

```swift
import SwiftData
import SwiftUI

/// アプリのメインタブ種別
enum AppTab: Hashable {
    case tasks
    case activity
}

@main
struct BabyStepsApp: App {
    @State private var selectedTab: AppTab = .tasks
    @State private var selectedFilter: TaskFilter = .all
    @State private var showingAddTask = false

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                TaskListView(
                    selectedTab: $selectedTab,
                    selectedFilter: $selectedFilter,
                    showingAddTask: $showingAddTask
                )
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("タスク")
                }
                .tag(AppTab.tasks)

                Group {
                    if selectedTab == .activity {
                        ActivityView(selectedTab: $selectedTab)
                    }
                    else {
                        Color.clear
                    }
                }
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("アクティビティ")
                }
                .tag(AppTab.activity)
            }
            .toolbar(.hidden, for: .tabBar)
            .modelContainer(for: [Task.self, TaskStep.self])
        }
    }
}
```

### 2. 削除するファイル

- `Sources/Views/MainView.swift`

### 3. その他

- `TaskListView`、`ActivityView` の変更は不要（MainView からの呼び出しが App に変わるだけ）

---

## 方針B：MainView を残す（現状維持）

**メリット**: 関心の分離、拡張性、SwiftUI の一般的な構成  
**デメリット**: ファイル1つ多い、小規模アプリではやや冗長

### 変更内容

- **変更なし**。現状の構成のまま。

### 現状の構成

```
BabyStepsApp (起動・モデルコンテナ)
  └── MainView (タブ・状態管理)
        └── TabView
              ├── TaskListView
              └── ActivityView
```

---

## 比較表

| 観点 | 方針A（削除） | 方針B（維持） |
|------|---------------|---------------|
| ファイル数 | 少ない | 多い |
| App の責務 | 起動 + UI + 状態 | 起動 + モデルのみ |
| 拡張時の変更箇所 | App が肥大化 | MainView に追加 |
| テスト・プレビュー | App は Scene のため難しい | MainView を単体でテスト可能 |

---

## 推奨

- **今後も機能追加を想定する** → 方針B（MainView 維持）
- **当面はシンプルさを優先する** → 方針A（MainView 削除）
