import SwiftUI

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
                if case .addTask = mode {
                    taskTitleInputView
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

// MARK: - Preview

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