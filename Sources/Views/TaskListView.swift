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
    @State private var newStepTitle = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // 全体進捗表示
                overallProgressView
                
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
            .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
                // データベースの変更を検知して必要に応じて更新
                // @Queryで自動更新されるため、ここでは特別な処理は不要
            }
        }
    }
    
    // MARK: - Overall Progress View
    
    private var overallProgressView: some View {
        VStack(spacing: 8) {
            Text("全体進捗")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack {
                ProgressView(value: calculateOverallProgress())
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(height: 8)
                
                Text("\(Int(calculateOverallProgress() * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
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
                
                Button("作成") {
                    if !newTaskTitle.isEmpty {
                        _ = viewModel?.createTask(title: newTaskTitle)
                        newTaskTitle = ""
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
                    
                    TextField("ステップのタイトル", text: $newStepTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button("追加") {
                        if !newStepTitle.isEmpty {
                            viewModel?.addStep(to: task, stepTitle: newStepTitle)
                            newStepTitle = ""
                            showingAddStep = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newStepTitle.isEmpty)
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
                        newStepTitle = ""
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
    
    private func calculateOverallProgress() -> Double {
        guard !tasks.isEmpty else { return 0.0 }
        let totalProgress = tasks.reduce(0.0) { $0 + $1.progress }
        return totalProgress / Double(tasks.count)
    }
    
    // 既存の完了済みステップにcompletedAtを設定
    private func initializeCompletedSteps() {
        for task in tasks {
            for step in task.steps {
                if step.isCompleted && step.completedAt == nil {
                    step.completedAt = Date()
                }
            }
        }
        try? modelContext.save()
    }
}

// MARK: - Task Row View

struct TaskRowView: View {
    let task: Task
    let viewModel: TaskViewModel?
    let onAddStep: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // タスクタイトルと進捗
            HStack {
                Text(task.title)
                    .font(.headline)
                
                Spacer()
                
                Button(action: onAddStep) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.blue)
                }
            }
            
            // 進捗バー
            HStack {
                ProgressView(value: task.progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(height: 6)
                
                Text("\(task.completedStepsCount)/\(task.totalStepsCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(viewModel == nil)
                            
                            Text(step.title)
                                .strikethrough(step.isCompleted)
                                .foregroundColor(step.isCompleted ? .secondary : .primary)
                            
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