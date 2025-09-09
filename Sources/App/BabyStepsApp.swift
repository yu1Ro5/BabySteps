import SwiftData
import SwiftUI

@main
struct BabyStepsApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            // モデルコンテナを作成（マイグレーション対応）
            modelContainer = try ModelContainer(
                for: Task.self, TaskStep.self, TaskMigrationPlan.self,
                migrationPlan: TaskMigrationPlan.self
            )
        } catch {
            fatalError("モデルコンテナの作成に失敗しました: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                TaskListView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("タスク")
                    }

                ActivityView()
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("アクティビティ")
                    }
            }
            .modelContainer(modelContainer)
            .onAppear {
                print("🚀 BabyStepsApp起動")
                performMigrationIfNeeded()
            }
        }
    }
    
    /// 必要に応じてマイグレーションを実行
    private func performMigrationIfNeeded() {
        let modelContext = modelContainer.mainContext
        
        // マイグレーションが必要かチェック
        if TaskMigrationPlan.isMigrationNeeded(modelContext: modelContext) {
            print("🔄 マイグレーションが必要です")
            
            // マイグレーション実行
            let success = TaskMigrationPlan.executeTaskCompletionMigration(modelContext: modelContext)
            
            if success {
                print("✅ マイグレーション完了")
                
                // データ整合性チェック
                let isValid = DataIntegrityChecker.performQuickCheck(modelContext: modelContext)
                if !isValid {
                    print("⚠️ データ整合性に問題があります。修復を実行します。")
                    _ = DataIntegrityChecker.performComprehensiveCheck(modelContext: modelContext)
                }
            } else {
                print("❌ マイグレーション失敗")
            }
        } else {
            print("✅ マイグレーション不要")
            
            // 既存データの整合性チェック
            let isValid = DataIntegrityChecker.performQuickCheck(modelContext: modelContext)
            if !isValid {
                print("⚠️ データ整合性に問題があります。修復を実行します。")
                _ = DataIntegrityChecker.performComprehensiveCheck(modelContext: modelContext)
            }
        }
    }
}
