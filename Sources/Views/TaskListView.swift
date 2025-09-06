import SwiftData
import SwiftUI

/// タスク一覧とタスク管理機能を提供する画面のビュー構造体です。
struct TaskListView: View {
    /// データ操作のためのSwiftDataモデルコンテキストです。
    @Environment(\.modelContext) private var modelContext
    /// SwiftDataストアから取得されたすべてのタスクです。
    @Query private var tasks: [Task]
    /// タスクやステップを管理するビューモデルです。
    @State private var viewModel: TaskViewModel?
    /// タスク追加シートの表示状態を管理します。
    @State private var showingAddTask = false
    /// 新しいタスクのタイトル入力を保持します。
    @State private var newTaskTitle = ""
    /// ステップ追加対象として選択中のタスクです。
    @State private var selectedTask: Task?
    /// 新しいタスク作成時のチェックボックス（ステップ）数（デフォルト: 5）。
    @State private var stepCount = 5
    /// ステップ追加時のステップ数（デフォルト: 1）。
    @State private var addStepCount = 1

    /// メイン画面のView階層を定義します。
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
            .sheet(item: $selectedTask) { task in
                addStepSheet(for: task)
            }
            .onAppear {
                // ModelContextを使用してViewModelを作成
                viewModel = TaskViewModel(modelContext: modelContext)

                // データ整合性チェックを実行
                performDataIntegrityChecks()
            }
        }
    }

    /// タスク一覧リストのViewを返します。
    private var taskList: some View {
        List {
            // 未完了のタスク
            if !incompleteTasks.isEmpty {
                Section("進行中") {
                    ForEach(incompleteTasks, id: \.id) { task in
                        TaskRowView(
                            task: task,
                            viewModel: viewModel,
                            onAddStep: { selectedTask = task }
                        )
                    }
                    .onDelete(perform: deleteIncompleteTasks)
                }
            }
            
            // 完了したタスク
            if !completedTasks.isEmpty {
                Section("完了済み") {
                    ForEach(completedTasks, id: \.id) { task in
                        TaskRowView(
                            task: task,
                            viewModel: viewModel,
                            onAddStep: { selectedTask = task }
                        )
                    }
                    .onDelete(perform: deleteCompletedTasks)
                }
            }
        }
    }

    /// 新しいタスク追加用のシートViewを返します。
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

    /// ステップ追加用のシートViewを返します。
    private func addStepSheet(for task: Task) -> some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("「\(task.title)」にステップを追加")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("このタスクに着手回数を追加します")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                // ステップ数選択UI
                VStack(spacing: 12) {
                    Text("追加するステップの数")
                        .font(.headline)
                        .foregroundColor(.primary)

                    HStack(spacing: 20) {
                        Button(action: {
                            if addStepCount > 1 {
                                addStepCount -= 1
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                        .disabled(addStepCount <= 1)

                        Text("\(addStepCount)")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(minWidth: 60)

                        Button(action: {
                            addStepCount += 1
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }

                    Text("\(addStepCount)個のステップが追加されます")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                Button("追加") {
                    for _ in 0..<addStepCount {
                        viewModel?.addStep(to: task)
                    }
                    addStepCount = 1  // リセット
                    selectedTask = nil
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding()
            .navigationTitle("ステップ追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        addStepCount = 1  // リセット
                        selectedTask = nil
                    }
                }
            }
        }
    }

    /// 未完了のタスクを取得
    private var incompleteTasks: [Task] {
        tasks.filter { !$0.isCompleted }
    }
    
    /// 完了したタスクを取得
    private var completedTasks: [Task] {
        tasks.filter { $0.isCompleted }
    }
    
    /// 指定されたインデックスの未完了タスクを削除します。
    /// - Parameter offsets: タスクのインデックス
    private func deleteIncompleteTasks(offsets: IndexSet) {
        for index in offsets {
            let task = incompleteTasks[index]
            viewModel?.deleteTask(task)
        }
    }
    
    /// 指定されたインデックスの完了タスクを削除します。
    /// - Parameter offsets: タスクのインデックス
    private func deleteCompletedTasks(offsets: IndexSet) {
        for index in offsets {
            let task = completedTasks[index]
            viewModel?.deleteTask(task)
        }
    }

    /// データ整合性チェックを実行します。
    private func performDataIntegrityChecks() {
        print("🔍 アプリ起動時のデータ整合性チェック開始")
        
        // DataIntegrityCheckerを使用してチェックを実行
        let checker = DataIntegrityChecker(modelContext: modelContext)
        checker.performStartupChecks()
        checker.printMigrationStatistics()
        
        print("🔍 データ整合性チェック完了")
    }
}

// MARK: - Task Row View

/// 1つのタスク情報とそのステップ進捗を表示するためのビュー構造体です。
struct TaskRowView: View {
    /// 表示対象のタスク。
    let task: Task
    /// タスク操作用のビューモデル（nilの可能性あり）。
    let viewModel: TaskViewModel?
    /// ＋ボタンがタップされた際に呼ばれるクロージャ。
    let onAddStep: () -> Void

    /// タスク名編集モードの状態
    @State private var isEditing = false
    /// 編集中のタスク名
    @State private var editingTitle = ""
    /// キーボードの表示状態
    @FocusState private var isTitleFieldFocused: Bool
    /// 変更があったかどうか
    @State private var hasChanges = false

    /// タスク1件の表示レイアウトを定義します。
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // タスクタイトル
            HStack {
                // リマインダーアプリ風の編集仕様
                HStack(spacing: 8) {
                    if isEditing {
                        // 編集モード：シンプルなTextField
                        TextField("タスク名", text: $editingTitle)
                            .textFieldStyle(PlainTextFieldStyle())
                            .focused($isTitleFieldFocused)
                            .onSubmit {
                                saveAndExitEditing()
                            }
                            .onChange(of: editingTitle) { _, newValue in
                                hasChanges = newValue != task.title
                            }
                            .font(.headline)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color(.systemGray5))
                            .cornerRadius(6)
                            .animation(.easeInOut(duration: 0.15), value: isEditing)
                            .accessibilityLabel("タスク名")
                            .accessibilityHint("編集中。完了するにはEnterキーを押すか、他の場所をタップしてください")
                            .accessibilityAddTraits([.isSelected])
                    }
                    else {
                        // 通常モード：タップ可能なテキスト
                        Text(task.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .onTapGesture {
                                startEditing()
                            }
                            .accessibilityLabel("タスク名")
                            .accessibilityHint("タップで編集を開始")
                    }
                }

                Spacer()
                
                // タスク全体の完了ボタン
                Button(action: {
                    guard let viewModel = viewModel else { return }
                    viewModel.toggleTaskCompletion(task)
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.isCompleted ? .green : .gray)
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(viewModel == nil)

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
            }
            else {
                Text("ステップがありません")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(task.isCompleted ? Color(.systemGray5) : Color(.systemGray6))
        .cornerRadius(12)
        .opacity(task.isCompleted ? 0.7 : 1.0)
        .onChange(of: isTitleFieldFocused) { _, isFocused in
            if !isFocused && isEditing {
                // リマインダーアプリ風：フォーカスが外れたら自動保存
                saveAndExitEditing()
            }
        }
    }

    // MARK: - Title Editing Methods

    /// タスク名の編集を開始します。
    private func startEditing() {
        editingTitle = task.title
        isEditing = true
        hasChanges = false
        isTitleFieldFocused = true
    }

    /// タスク名の編集を保存して編集モードを終了します。
    private func saveAndExitEditing() {
        let trimmedTitle = editingTitle.trimmingCharacters(in: .whitespacesAndNewlines)

        // リマインダーアプリ風：空文字列の場合は元のタイトルに戻す
        if trimmedTitle.isEmpty {
            cancelEditing()
            return
        }

        // 変更がある場合のみ保存
        if trimmedTitle != task.title {
            viewModel?.updateTaskTitle(task, newTitle: trimmedTitle)
        }

        // 編集モードを終了
        isEditing = false
        isTitleFieldFocused = false
        hasChanges = false
    }

    /// タスク名の編集をキャンセルします。
    private func cancelEditing() {
        isEditing = false
        isTitleFieldFocused = false
        hasChanges = false
        editingTitle = ""
    }
}

#Preview {
    TaskListView()
        .modelContainer(for: Task.self, inMemory: true)
}
