import SwiftUI

struct Memory: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let date: Date
    let imageName: String
    let category: MemoryCategory
}

enum MemoryCategory: String, CaseIterable {
    case firsts = "Firsts"
    case daily = "Daily"
    case special = "Special"
    case family = "Family"
    
    var icon: String {
        switch self {
        case .firsts: return "star.fill"
        case .daily: return "sun.max.fill"
        case .special: return "gift.fill"
        case .family: return "heart.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .firsts: return .yellow
        case .daily: return .orange
        case .special: return .pink
        case .family: return .red
        }
    }
}

struct MemoriesView: View {
    @State private var memories: [Memory] = [
        Memory(title: "First Bath", description: "Baby's first bath at home - so tiny and precious!", date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(), imageName: "bath", category: .firsts),
        Memory(title: "Family Photo", description: "First family photo with grandparents", date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), imageName: "family", category: .family),
        Memory(title: "Tummy Time", description: "Baby loves tummy time and is getting stronger", date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), imageName: "tummy", category: .daily),
        Memory(title: "First Gift", description: "Received first teddy bear from auntie", date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(), imageName: "gift", category: .special)
    ]
    
    @State private var selectedCategory: MemoryCategory? = nil
    @State private var showingAddMemory = false
    
    var filteredMemories: [Memory] {
        if let category = selectedCategory {
            return memories.filter { $0.category == category }
        }
        return memories
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    Button(action: {
                        selectedCategory = nil
                    }) {
                        Text("All")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedCategory == nil ? Color.blue : Color(.systemGray5))
                            .foregroundColor(selectedCategory == nil ? .white : .primary)
                            .cornerRadius(20)
                    }
                    
                    ForEach(MemoryCategory.allCases, id: \.self) { category in
                        Button(action: {
                            selectedCategory = selectedCategory == category ? nil : category
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? category.color.opacity(0.2) : Color(.systemGray5))
                            .foregroundColor(selectedCategory == category ? category.color : .primary)
                            .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 10)
            
            // Memories Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    ForEach(filteredMemories.sorted(by: { $0.date > $1.date })) { memory in
                        MemoryCard(memory: memory)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Memories")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(trailing: Button(action: {
            showingAddMemory = true
        }) {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.blue)
                .font(.title2)
        })
        .sheet(isPresented: $showingAddMemory) {
            AddMemoryView(memories: $memories)
        }
    }
}

struct MemoryCard: View {
    let memory: Memory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Placeholder for image
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(memory.category.color.opacity(0.2))
                    .frame(height: 120)
                
                Image(systemName: memory.category.icon)
                    .font(.system(size: 40))
                    .foregroundColor(memory.category.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(memory.title)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    Text(memory.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(memory.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(memory.category.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(memory.category.color.opacity(0.2))
                        .foregroundColor(memory.category.color)
                        .cornerRadius(8)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct AddMemoryView: View {
    @Binding var memories: [Memory]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory: MemoryCategory = .daily
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Memory Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(MemoryCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Memory")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    if !title.isEmpty && !description.isEmpty {
                        let newMemory = Memory(
                            title: title,
                            description: description,
                            date: selectedDate,
                            imageName: "placeholder",
                            category: selectedCategory
                        )
                        memories.append(newMemory)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(title.isEmpty || description.isEmpty)
            )
        }
    }
}

struct MemoriesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MemoriesView()
        }
    }
}