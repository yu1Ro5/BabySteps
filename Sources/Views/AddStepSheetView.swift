import SwiftUI

struct AddStepSheetView: View {
    // MARK: - Properties
    
    let task: Task
    @Binding var isPresented: Bool
    @State private var stepCount = 1
    
    let onConfirm: (Int) -> Void
    let onCancel: () -> Void
    
    // MARK: - Initializer
    
    init(
        task: Task,
        isPresented: Binding<Bool>,
        onConfirm: @escaping (Int) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.task = task
        self._isPresented = isPresented
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // タスク情報
                VStack(spacing: 8) {
                    Text("「\(task.title)」にステップを追加")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("このタスクに着手回数を追加します")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // ステップ数選択UI（共通コンポーネントを使用）
                TaskStepSheetView(
                    title: "追加するステップ数",
                    description: "一度に追加するチェックボックスの数を選択してください",
                    confirmButtonTitle: "追加",
                    stepCount: $stepCount,
                    isPresented: $isPresented,
                    onConfirm: {
                        onConfirm(stepCount)
                        resetForm()
                    },
                    onCancel: {
                        onCancel()
                        resetForm()
                    }
                )
                
                Spacer()
            }
            .padding()
            .navigationTitle("ステップ追加")
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
    
    // MARK: - Helper Methods
    
    private func resetForm() {
        stepCount = 1
    }
}

// MARK: - Preview

#Preview {
    let task = Task(title: "サンプルタスク")
    return AddStepSheetView(
        task: task,
        isPresented: .constant(true),
        onConfirm: { _ in },
        onCancel: {}
    )
}