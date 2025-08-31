import SwiftUI

struct EditTaskSheetView: View {
    let task: Task
    let isPresented: Binding<Bool>
    let onConfirm: (String) -> Void
    let onCancel: () -> Void
    
    @State private var editedTitle: String
    
    init(task: Task, isPresented: Binding<Bool>, onConfirm: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
        self.task = task
        self.isPresented = isPresented
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        self._editedTitle = State(initialValue: task.title)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // タイトル入力フィールド
                VStack(alignment: .leading, spacing: 8) {
                    Text("タスク名")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("タスク名を入力", text: $editedTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("タスクを編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        if !editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            onConfirm(editedTitle.trimmingCharacters(in: .whitespacesAndNewlines))
                        }
                    }
                    .disabled(editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    EditTaskSheetView(
        task: Task(title: "サンプルタスク"),
        isPresented: .constant(true),
        onConfirm: { _ in },
        onCancel: {}
    )
}