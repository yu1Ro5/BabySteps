import SwiftUI
import SwiftData

// 共通コンポーネントのインポート
@_exported import struct Sources.Views.TaskStepSheetView
@_exported import struct Sources.Views.AddTaskSheetView
@_exported import struct Sources.Views.AddStepSheetView

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [Task]
    @State private var viewModel: TaskViewModel?
    @State private var showingAddTask = false
    @State private var selectedTask: Task?
    @State private var showingAddStep = false

    
    var body: some View {
        NavigationStack {
            VStack {
                // タスク一覧
                taskList
            }
            .navigationTitle("BabySteps")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskSheetView(
                    isPresented: $showingAddTask,
                    onConfirm: { title, stepCount in
                        _ = viewModel?.createTaskWithSteps(title: title, stepCount: stepCount)
                        showingAddTask = false
                    },
                    onCancel: {
                        showingAddTask = false
                    }
                )
            }
            .sheet(isPresented: $showingAddStep) {
                if let task = selectedTask {
                    AddStepSheetView(
                        task: task,
                        isPresented: $showingAddStep,
                        onConfirm: { stepCount in
                            viewModel?.addMultipleSteps(to: task, count: stepCount)
                            showingAddStep = false
                        },
                        onCancel: {
                            showingAddStep = false
                        }
                    )
                }
            }
            .onAppear {
                // ModelContextを使用してViewModelを作成
                viewModel = TaskViewModel(modelContext: modelContext)
                
                // 既存の完了済みステップにcompletedAtを設定
                initializeCompletedSteps()
            }
        }
    }
    

    
    // MARK: - Task List
    
    private var taskList: some View {
        List {
            ForEach(tasks, id: \.id) { task in
                TaskRowView(
                    task: task,
                    viewModel: viewModel,
                    onAddStep: { selectedTask = task; showingAddStep = true }
                )
            }
            .onDelete(perform: deleteTasks)
        }
    }
    
    // MARK: - Add Task Sheet
    
    // 共通コンポーネントを使用するため、このセクションは削除
    
    // MARK: - Add Step Sheet
    
    // 共通コンポーネントを使用するため、このセクションは削除
    
    // MARK: - Helper Methods
    
    private func deleteTasks(offsets: IndexSet) {
        for index in offsets {
            viewModel?.deleteTask(tasks[index])
        }
    }
    

    
    // 既存の完了済みステップにcompletedAtを設定
    private func initializeCompletedSteps() {
        var hasChanges = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        
        print("🔧 完了済みステップの初期化開始")
        
        for task in tasks {
            print("🔧 タスク: \(task.title)")
            for step in task.steps {
                if step.isCompleted {
                    if step.completedAt == nil {
                        // 完了済みだがcompletedAtが設定されていない場合
                        step.completedAt = Date()
                        hasChanges = true
                        print("  ✅ ステップ\(step.order + 1) - completedAtを設定: \(dateFormatter.string(from: step.completedAt!))")
                    } else {
                        print("  ℹ️ ステップ\(step.order + 1) - 既にcompletedAt設定済み: \(dateFormatter.string(from: step.completedAt!))")
                    }
                } else {
                    print("  ⏳ ステップ\(step.order + 1) - 未完了")
                }
            }
        }
        
        if hasChanges {
            print("🔧 変更を保存中...")
            try? modelContext.save()
            print("🔧 保存完了")
        } else {
            print("🔧 変更なし")
        }
    }
}

// MARK: - Task Row View

struct TaskRowView: View {
    let task: Task
    let viewModel: TaskViewModel?
    let onAddStep: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // タスクタイトル
            HStack {
                Text(task.title)
                    .font(.headline)
                
                Spacer()
                
                Button(action: onAddStep) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.blue)
                }
            }
            

            
            // ステップ一覧
            if !task.steps.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                    ForEach(task.steps.sorted(by: { $0.order < $1.order }), id: \.id) { step in
                        Button(action: {
                            guard let viewModel = viewModel else { return }
                            viewModel.toggleStepCompletion(step)
                        }) {
                            Image(systemName: step.isCompleted ? "checkmark.square.fill" : "square")
                                .foregroundColor(step.isCompleted ? .green : .gray)
                                .font(.title2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(viewModel == nil)
                    }
                }
                .padding(.leading)
            } else {
                Text("ステップがありません")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    TaskListView()
        .modelContainer(for: Task.self, inMemory: true)
}