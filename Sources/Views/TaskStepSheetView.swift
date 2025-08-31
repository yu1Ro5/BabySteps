import SwiftUI

struct TaskStepSheetView: View {
    // MARK: - Properties
    
    let title: String
    let description: String
    let confirmButtonTitle: String
    let cancelButtonTitle: String
    
    @Binding var stepCount: Int
    @Binding var isPresented: Bool
    
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    // MARK: - Initializer
    
    init(
        title: String,
        description: String,
        confirmButtonTitle: String,
        cancelButtonTitle: String = "キャンセル",
        stepCount: Binding<Int>,
        isPresented: Binding<Bool>,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.confirmButtonTitle = confirmButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
        self._stepCount = stepCount
        self._isPresented = isPresented
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // タイトル
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                // 説明
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // ステップ数選択UI
                stepCountSelector
                
                // 確認ボタン
                Button(confirmButtonTitle) {
                    onConfirm()
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            .navigationTitle("ステップ設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(cancelButtonTitle) {
                        onCancel()
                    }
                }
            }
        }
    }
    
    // MARK: - Step Count Selector
    
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
}

// MARK: - Preview

#Preview {
    TaskStepSheetView(
        title: "新しいタスクを作成",
        description: "タスクのタイトルとステップ数を設定してください",
        confirmButtonTitle: "作成",
        stepCount: .constant(5),
        isPresented: .constant(true),
        onConfirm: {},
        onCancel: {}
    )
}
