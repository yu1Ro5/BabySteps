import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [Task]
    @State private var viewModel: TaskViewModel?
    @State private var showingAddTask = false
    @State private var newTaskTitle = ""
    @State private var selectedTask: Task?
    @State private var showingAddStep = false
    @State private var stepCount = 5  // デフォルトのステップ数

    
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
                addTaskSheet
            }
            .sheet(isPresented: $showingAddStep) {
                addStepSheet
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
    
    private var addTaskSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("新しいタスクを作成")
                    .font(.title2)
                    .fontWeight(.bold)
                
                TextField("タスクのタイトル", text: $newTaskTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // ステップ数選択UI
                VStack(spacing: 12) {
                    Text("チェックボックスの数")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            if stepCount > 1 {
                                stepCount -= 1
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                        .disabled(stepCount <= 1)
                        
                        Text("\(stepCount)")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(minWidth: 60)
                        
                        Button(action: {
                            stepCount += 1
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Text("\(stepCount)個のチェックボックスが作成されます")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Button("作成") {
                    if !newTaskTitle.isEmpty {
                        _ = viewModel?.createTaskWithSteps(title: newTaskTitle, stepCount: stepCount)
                        newTaskTitle = ""
                        stepCount = 5  // リセット
                        showingAddTask = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(newTaskTitle.isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationTitle("タスク追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        showingAddTask = false
                        newTaskTitle = ""
                        stepCount = 5  // リセット
                    }
                }
            }
        }
    }
    
    // MARK: - Add Step Sheet
    
    private var addStepSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let task = selectedTask {
                    Text("「\(task.title)」にステップを追加")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("このタスクに着手回数を追加します")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("追加") {
                        viewModel?.addStep(to: task)
                        showingAddStep = false
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("ステップ追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        showingAddStep = false
                    }
                }
            }
        }
    }
    
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
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(task.steps.sorted(by: { $0.order < $1.order }), id: \.id) { step in
                        HStack {
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
                            
                            Spacer()
                        }
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