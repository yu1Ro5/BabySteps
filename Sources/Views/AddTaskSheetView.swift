import SwiftUI

struct AddTaskSheetView: View {
    // MARK: - Properties
    
    @Binding var isPresented: Bool
    @State private var taskTitle = ""
    @State private var stepCount = 5
    
    let onConfirm: (String, Int) -> Void
    let onCancel: () -> Void
    
    // MARK: - Initializer
    
    init(
        isPresented: Binding<Bool>,
        onConfirm: @escaping (String, Int) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self._isPresented = isPresented
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // タイトル
                Text("新しいタスクを作成")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // タスクタイトル入力フィールド
                VStack(alignment: .leading, spacing: 8) {
                    Text("タスクのタイトル")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("タスクのタイトル", text: $taskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // ステップ数選択UI（共通コンポーネントを使用）
                TaskStepSheetView(
                    title: "ステップ数を設定",
                    description: "このタスクに必要なチェックボックスの数を選択してください",
                    confirmButtonTitle: "作成",
                    stepCount: $stepCount,
                    isPresented: $isPresented,
                    onConfirm: {
                        if !taskTitle.isEmpty {
                            onConfirm(taskTitle, stepCount)
                            resetForm()
                        }
                    },
                    onCancel: {
                        onCancel()
                        resetForm()
                    }
                )
                .disabled(taskTitle.isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationTitle("タスク追加")
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
        taskTitle = ""
        stepCount = 5
    }
}

// MARK: - Preview

#Preview {
    AddTaskSheetView(
        isPresented: .constant(true),
        onConfirm: { _, _ in },
        onCancel: {}
    )
}