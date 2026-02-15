import SwiftData
import SwiftUI

/// 新規タスク追加用のシートビュー。TaskListView から表示し、タスクタブのみで利用可能。
struct AddTaskSheetView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool

    @State private var newTaskTitle = ""
    @State private var stepCount = 5

    var body: some View {
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
                        let viewModel = TaskViewModel(modelContext: modelContext)
                        _ = viewModel.createTaskWithSteps(title: newTaskTitle, stepCount: stepCount)
                        newTaskTitle = ""
                        stepCount = 5
                        isPresented = false
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
                        isPresented = false
                        newTaskTitle = ""
                        stepCount = 5
                    }
                }
            }
        }
    }
}
