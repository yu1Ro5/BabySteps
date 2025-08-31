import SwiftUI
import SwiftData

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
                TaskStepSheetView(
                    mode: .addTask,
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
                    TaskStepSheetView(
                        mode: .addStep(task),
                        isPresented: $showingAddStep,
                        onConfirm: { _, stepCount in
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

// MARK: - Task Step Sheet View

struct TaskStepSheetView: View {
    // MARK: - Properties
    
    enum Mode {
        case addTask
        case addStep(Task)
    }
    
    let mode: Mode
    @Binding var isPresented: Bool
    @State private var taskTitle = ""
    @State private var stepCount: Int
    
    let onConfirm: (String, Int) -> Void
    let onCancel: () -> Void
    
    // MARK: - Initializer
    
    init(
        mode: Mode,
        isPresented: Binding<Bool>,
        onConfirm: @escaping (String, Int) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.mode = mode
        self._isPresented = isPresented
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        
        // モードに応じてデフォルト値を設定
        switch mode {
        case .addTask:
            self._stepCount = State(initialValue: 5)
        case .addStep:
            self._stepCount = State(initialValue: 1)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // タイトル
                titleView
                
                // 説明
                descriptionView
                
                // タスクタイトル入力（addTaskモードのみ）
                switch mode {
                case .addTask:
                    taskTitleInputView
                case .addStep:
                    EmptyView()
                }
                
                // ステップ数選択UI
                stepCountSelector
                
                // 確認ボタン
                confirmButton
                
                Spacer()
            }
            .padding()
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        onCancel()
                        resetForm()
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var navigationTitle: String {
        switch mode {
        case .addTask:
            return "タスク追加"
        case .addStep:
            return "ステップ追加"
        }
    }
    
    private var confirmButtonTitle: String {
        switch mode {
        case .addTask:
            return "作成"
        case .addStep:
            return "追加"
        }
    }
    
    // MARK: - View Components
    
    private var titleView: some View {
        Text(titleText)
            .font(.title2)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
    }
    
    private var titleText: String {
        switch mode {
        case .addTask:
            return "新しいタスクを作成"
        case .addStep(let task):
            return "「\(task.title)」にステップを追加"
        }
    }
    
    private var descriptionView: some View {
        Text(descriptionText)
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
    }
    
    private var descriptionText: String {
        switch mode {
        case .addTask:
            return "タスクのタイトルとステップ数を設定してください"
        case .addStep:
            return "このタスクに着手回数を追加します"
        }
    }
    
    private var taskTitleInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("タスクのタイトル")
                .font(.headline)
                .foregroundColor(.primary)
            
            TextField("タスクのタイトル", text: $taskTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }
    
    private var stepCountSelector: some View {
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
    }
    
    private var confirmButton: some View {
        Button(confirmButtonTitle) {
            let finalTaskTitle = (mode == .addTask) ? taskTitle : ""
            onConfirm(finalTaskTitle, stepCount)
            resetForm()
        }
        .buttonStyle(.borderedProminent)
        .disabled(mode == .addTask && taskTitle.isEmpty)
    }
    
    // MARK: - Helper Methods
    
    private func resetForm() {
        taskTitle = ""
        switch mode {
        case .addTask:
            stepCount = 5
        case .addStep:
            stepCount = 1
        }
    }
}

// MARK: - Task Step Sheet Preview

#Preview("Add Task") {
    TaskStepSheetView(
        mode: .addTask,
        isPresented: .constant(true),
        onConfirm: { _, _ in },
        onCancel: {}
    )
}

#Preview("Add Step") {
    let task = Task(title: "サンプルタスク")
    return TaskStepSheetView(
        mode: .addStep(task),
        isPresented: .constant(true),
        onConfirm: { _, _ in },
        onCancel: {}
    )
}
