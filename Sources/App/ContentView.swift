import SwiftUI

struct Task: Identifiable {
    let id = UUID()
    let title: String
    var attemptCount: Int
    let targetCount: Int
    let category: TaskCategory
}

enum TaskCategory: String, CaseIterable {
    case work = "Work"
    case personal = "Personal"
    case learning = "Learning"
    case health = "Health"
    
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .learning: return "book.fill"
        case .health: return "heart.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .work: return .blue
        case .personal: return .green
        case .learning: return .orange
        case .health: return .red
        }
    }
}

struct ContentView: View {
    @State private var tasks: [Task] = [
        Task(title: "Complete project proposal", attemptCount: 3, targetCount: 5, category: .work),
        Task(title: "Learn SwiftUI", attemptCount: 7, targetCount: 10, category: .learning),
        Task(title: "Exercise routine", attemptCount: 2, targetCount: 5, category: .health),
        Task(title: "Read book", attemptCount: 1, targetCount: 3, category: .personal)
    ]
    
    @State private var showingAddTask = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("BabySteps")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Track your attempts, not just completions")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Tasks List
                List {
                    ForEach(tasks) { task in
                        TaskRow(task: task) { updatedTask in
                            if let index = tasks.firstIndex(where: { $0.id == updatedTask.id }) {
                                tasks[index] = updatedTask
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                
                // Add Task Button
                Button(action: {
                    showingAddTask = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add New Task")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(tasks: $tasks)
            }
        }
    }
}

struct TaskRow: View {
    let task: Task
    let onUpdate: (Task) -> Void
    
    var body: some View {
        HStack {
            // Category Icon
            Image(systemName: task.category.icon)
                .foregroundColor(task.category.color)
                .font(.title2)
                .frame(width: 30)
            
            // Task Info
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                
                HStack {
                    Text("\(task.attemptCount)/\(task.targetCount) attempts")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(task.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(task.category.color.opacity(0.2))
                        .foregroundColor(task.category.color)
                        .cornerRadius(8)
                }
            }
            
            Spacer()
            
            // Attempt Button
            Button(action: {
                var updatedTask = task
                updatedTask.attemptCount += 1
                onUpdate(updatedTask)
            }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddTaskView: View {
    @Binding var tasks: [Task]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var selectedCategory: TaskCategory = .work
    @State private var targetCount = 3
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task Title", text: $title)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    
                    Stepper("Target Attempts: \(targetCount)", value: $targetCount, in: 1...20)
                }
            }
            .navigationTitle("Add New Task")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    if !title.isEmpty {
                        let newTask = Task(
                            title: title,
                            attemptCount: 0,
                            targetCount: targetCount,
                            category: selectedCategory
                        )
                        tasks.append(newTask)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(title.isEmpty)
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}