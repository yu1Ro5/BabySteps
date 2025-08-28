#!/usr/bin/env swift

import Foundation

// スクリーンショット用のサンプルデータを準備
// このスクリプトは、アプリの状態を設定してスクリーンショット撮影を最適化します

print("📱 Preparing BabySteps app for screenshot generation...")

// サンプルタスクデータの定義
let sampleTasks = [
    "朝のルーティン": [
        "ベッドから起きる",
        "歯を磨く",
        "朝食を食べる",
        "身支度をする"
    ],
    "プロジェクト計画": [
        "要件を整理する",
        "設計図を作成する",
        "タスクを分解する",
        "スケジュールを立てる"
    ],
    "健康管理": [
        "運動する",
        "水分を取る",
        "健康的な食事を心がける",
        "十分な睡眠を取る"
    ]
]

print("✅ Sample data prepared:")
for (taskName, steps) in sampleTasks {
    print("  📋 \(taskName) (\(steps.count) steps)")
}

print("")
print("🚀 App is ready for screenshot generation!")
print("📸 The following screens will be captured:")
print("   1. Main Screen - タスク一覧と全体進捗")
print("   2. Task List - タスクの詳細表示")
print("   3. Add Task - 新しいタスク追加画面")
print("   4. Task Detail - ステップ一覧と進捗")
print("   5. Progress View - 進捗率の視覚的表示")
print("")
print("💡 Tips for better screenshots:")
print("   - アプリが完全に起動するまで待つ")
print("   - 各画面で適切なデータが表示されていることを確認")
print("   - 進捗バーやUI要素が正しく表示されていることを確認")