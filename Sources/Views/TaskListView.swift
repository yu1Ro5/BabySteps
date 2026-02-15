import SwiftData
import SwiftUI

/// タスク一覧とタスク管理機能を提供する画面のビュー構造体です。
struct TaskListView: View {
    /// フィルター種別
    @Binding var selectedFilter: TaskFilter
    /// タスク追加シートの表示状態
    @State private var showingAddTask = false

    /// データ操作のためのSwiftDataモデルコンテキストです。
    @Environment(\.modelContext) private var modelContext
    /// SwiftDataストアから取得されたすべてのタスクです。
    @Query(sort: \Task.createdAt, order: .reverse) private var tasks: [Task]
    /// タスクやステップを管理するビューモデルです。
    @State private var viewModel: TaskViewModel?
    /// ステップ追加対象として選択中のタスクです。
    @State private var selectedTask: Task?
    /// ステップ追加時のステップ数（デフォルト: 1）。
    @State private var addStepCount = 1
    /// 既存データの軽量マイグレーションを1回だけ実行するためのフラグです。
    @State private var didBackfillCompletedAt = false

    /// フィルター適用後のタスク一覧
    private var filteredTasks: [Task] {
        var result = tasks
        switch selectedFilter {
        case .all:
            break
        case .inProgress:
            result = result.filter { !$0.steps.isEmpty && !$0.isCompleted }
        case .completed:
            result = result.filter(\.isCompleted)
        }
        return result
    }

    /// メイン画面のView階層を定義します。
    var body: some View {
        NavigationStack {
            VStack {
                // タスク一覧
                taskList
            }
            .navigationTitle("BabySteps")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("フィルター", selection: $selectedFilter) {
                            ForEach(TaskFilter.allCases, id: \.self) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskSheetView(isPresented: $showingAddTask)
            }
            .sheet(item: $selectedTask) { task in
                addStepSheet(for: task)
            }
            .onAppear {
                // ModelContextを使用してViewModelを作成
                viewModel = TaskViewModel(modelContext: modelContext)

                // 既存の完了済みステップにcompletedAtを設定
                if !didBackfillCompletedAt {
                    didBackfillCompletedAt = true
                    initializeCompletedSteps()
                }
            }
        }
    }

    /// タスク一覧リストのViewを返します。
    private var taskList: some View {
        Group {
            if filteredTasks.isEmpty {
                ContentUnavailableView(
                    "該当するタスクがありません",
                    systemImage: "magnifyingglass",
                    description: Text(emptyStateDescription)
                )
            }
            else {
                List {
                    ForEach(filteredTasks, id: \.id) { task in
                        TaskRowView(
                            task: task,
                            viewModel: viewModel,
                            onAddStep: { selectedTask = task }
                        )
                    }
                    .onDelete(perform: deleteTasks)
                }
            }
        }
    }

    /// 空状態時の説明文（フィルターで0件か、タスクが全くないかで分岐）
    private var emptyStateDescription: String {
        if tasks.isEmpty {
            return "タスクを追加してください"
        }
        return "フィルターを変えてみてください"
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

    /// 指定されたインデックスのタスクを削除します。
    /// - Parameter offsets: filteredTasks のインデックス
    private func deleteTasks(offsets: IndexSet) {
        for index in offsets {
            viewModel?.deleteTask(filteredTasks[index])
        }
    }

    /// 既存の完了済みステップにcompletedAtの日付を設定します。
    private func initializeCompletedSteps() {
        let predicate = #Predicate<TaskStep> { step in
            step.isCompleted && step.completedAt == nil
        }
        let descriptor = FetchDescriptor<TaskStep>(predicate: predicate)

        guard let stepsNeedingBackfill = try? modelContext.fetch(descriptor),
            !stepsNeedingBackfill.isEmpty
        else { return }

        let now = Date()
        for step in stepsNeedingBackfill {
            step.completedAt = now
        }
        try? modelContext.save()
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
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .contentShape(Rectangle())
        .onTapGesture {
            // 編集中のテキストフィールド以外をタップした時にキーボードを閉じる
            if isEditing {
                isTitleFieldFocused = false
            }
        }
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
    struct PreviewWrapper: View {
        @State private var filter = TaskFilter.all

        var body: some View {
            TaskListView(selectedFilter: $filter)
                .modelContainer(for: [Task.self, TaskStep.self], inMemory: true)
        }
    }
    return PreviewWrapper()
}
