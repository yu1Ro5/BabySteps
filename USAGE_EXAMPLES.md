# BabySteps Usage Examples

This document provides practical examples of how to use the BabySteps APIs and extend the application with new features.

## Table of Contents

1. [Basic Usage](#basic-usage)
2. [Data Operations](#data-operations)
3. [UI Customization](#ui-customization)
4. [Extending the Model](#extending-the-model)
5. [Advanced Features](#advanced-features)
6. [Testing Examples](#testing-examples)

---

## Basic Usage

### Running the Application

1. **Open in Xcode**:
   ```bash
   open BabySteps.xcodeproj
   ```

2. **Select Target Device**:
   - iOS Simulator (recommended for development)
   - Physical iOS device (iOS 17.0+)

3. **Build and Run**:
   - Press `Cmd + R` or click the Run button
   - The app will launch with an empty list

### Basic User Interactions

1. **Adding Items**:
   - Tap the "+" button in the top-right corner
   - A new timestamped item appears in the list

2. **Viewing Items**:
   - Items are displayed with timestamps
   - Tap an item to view details (currently shows placeholder)

3. **Deleting Items**:
   - Swipe left on any item to reveal delete button
   - Tap "Delete" or use Edit mode for multiple deletions

---

## Data Operations

### Creating Items

#### Basic Item Creation

```swift
// Create item with current timestamp
let newItem = Item(timestamp: Date())
modelContext.insert(newItem)

// Create item with custom timestamp
let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
let customItem = Item(timestamp: yesterday)
modelContext.insert(customItem)
```

#### Batch Item Creation

```swift
// Create multiple items
func createSampleData() {
    let sampleDates = [
        Date(),
        Calendar.current.date(byAdding: .hour, value: -1, to: Date())!,
        Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    ]
    
    for date in sampleDates {
        let item = Item(timestamp: date)
        modelContext.insert(item)
    }
}
```

### Reading Items

#### Basic Query

```swift
// Query all items (current implementation)
@Query private var items: [Item]

// Display items in list
ForEach(items) { item in
    Text(item.timestamp, format: .dateTime)
}
```

#### Filtered Queries

```swift
// Query recent items (last 24 hours)
@Query(filter: #Predicate<Item> { item in
    item.timestamp > Calendar.current.date(byAdding: .day, value: -1, to: Date())!
}) private var recentItems: [Item]

// Query items from specific date range
@Query(filter: #Predicate<Item> { item in
    let startDate = Calendar.current.startOfDay(for: Date())
    let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
    return item.timestamp >= startDate && item.timestamp < endDate
}) private var todayItems: [Item]
```

#### Sorted Queries

```swift
// Sort by timestamp (newest first)
@Query(sort: [SortDescriptor(\Item.timestamp, order: .reverse)]) 
private var sortedItems: [Item]

// Sort by timestamp (oldest first)
@Query(sort: [SortDescriptor(\Item.timestamp, order: .forward)]) 
private var chronologicalItems: [Item]
```

### Updating Items

#### Basic Update

```swift
// Update item timestamp
func updateItem(_ item: Item, newTimestamp: Date) {
    item.timestamp = newTimestamp
    // Changes are automatically saved
}

// Update multiple items
func updateAllItems() {
    for item in items {
        item.timestamp = Date() // Set all to current time
    }
}
```

#### Conditional Updates

```swift
// Update items older than 1 hour
func updateOldItems() {
    let oneHourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
    
    for item in items where item.timestamp < oneHourAgo {
        item.timestamp = Date()
    }
}
```

### Deleting Items

#### Basic Deletion

```swift
// Delete single item
func deleteItem(_ item: Item) {
    modelContext.delete(item)
}

// Delete item at index
func deleteItemAt(_ index: Int) {
    guard index < items.count else { return }
    modelContext.delete(items[index])
}
```

#### Batch Deletion

```swift
// Delete all items
func deleteAllItems() {
    for item in items {
        modelContext.delete(item)
    }
}

// Delete old items
func deleteOldItems() {
    let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    
    for item in items where item.timestamp < oneDayAgo {
        modelContext.delete(item)
    }
}

// Delete items by condition
func deleteItems(where predicate: (Item) -> Bool) {
    let itemsToDelete = items.filter(predicate)
    for item in itemsToDelete {
        modelContext.delete(item)
    }
}
```

---

## UI Customization

### Customizing the List View

#### Enhanced Item Display

```swift
struct EnhancedItemRow: View {
    let item: Item
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.timestamp, format: .dateTime)
                    .font(.headline)
                Text(timeAgoString(from: item.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "clock")
                .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
```

#### Custom List Styling

```swift
List {
    ForEach(items) { item in
        EnhancedItemRow(item: item)
    }
    .onDelete(perform: deleteItems)
}
.listStyle(InsetGroupedListStyle())
.refreshable {
    // Pull to refresh functionality
    await refreshData()
}
```

### Enhanced Toolbar

#### Custom Toolbar Items

```swift
.toolbar {
    ToolbarItem(placement: .navigationBarLeading) {
        Button("Clear All") {
            showClearAllAlert = true
        }
        .foregroundColor(.red)
    }
    
    ToolbarItem(placement: .navigationBarTrailing) {
        EditButton()
    }
    
    ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: addItem) {
            Label("Add Item", systemImage: "plus")
        }
    }
    
    ToolbarItem(placement: .navigationBarTrailing) {
        Menu {
            Button("Add 5 Items") { addMultipleItems(5) }
            Button("Add 10 Items") { addMultipleItems(10) }
            Divider()
            Button("Export Data") { exportData() }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}
```

### Search Functionality

#### Search Bar Implementation

```swift
struct SearchableContentView: View {
    @State private var searchText = ""
    @Query private var allItems: [Item]
    
    var filteredItems: [Item] {
        if searchText.isEmpty {
            return allItems
        } else {
            return allItems.filter { item in
                item.timestamp.description.localizedStandardContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredItems) { item in
                ItemRow(item: item)
            }
            .searchable(text: $searchText, prompt: "Search timestamps")
            .navigationTitle("Items")
        }
    }
}
```

---

## Extending the Model

### Adding New Properties

#### Enhanced Item Model

```swift
@Model
final class Item {
    var timestamp: Date
    var title: String
    var notes: String?
    var priority: Priority
    var tags: [String]
    var isCompleted: Bool
    
    init(timestamp: Date, title: String = "", notes: String? = nil, 
         priority: Priority = .medium, tags: [String] = [], isCompleted: Bool = false) {
        self.timestamp = timestamp
        self.title = title
        self.notes = notes
        self.priority = priority
        self.tags = tags
        self.isCompleted = false
    }
}

enum Priority: Int, CaseIterable, Codable {
    case low = 0
    case medium = 1
    case high = 2
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}
```

#### Updated Schema

```swift
// In BabyStepsApp.swift
let schema = Schema([
    Item.self,
])
```

### Adding Relationships

#### Category Model

```swift
@Model
final class Category {
    var name: String
    var color: String // Store as hex string
    var items: [Item]?
    
    init(name: String, color: String = "#007AFF") {
        self.name = name
        self.color = color
    }
}

// Update Item model
@Model
final class Item {
    var timestamp: Date
    var title: String
    var category: Category?
    // ... other properties
}
```

---

## Advanced Features

### Data Export

#### Export to JSON

```swift
func exportToJSON() -> String? {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = .prettyPrinted
    
    do {
        let data = try encoder.encode(items)
        return String(data: data, encoding: .utf8)
    } catch {
        print("Export failed: \(error)")
        return nil
    }
}

func shareData() {
    guard let jsonString = exportToJSON() else { return }
    
    let activityVC = UIActivityViewController(
        activityItems: [jsonString],
        applicationActivities: nil
    )
    
    // Present the activity view controller
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first {
        window.rootViewController?.present(activityVC, animated: true)
    }
}
```

#### Export to CSV

```swift
func exportToCSV() -> String {
    var csv = "Timestamp,Title,Notes,Priority,Completed\n"
    
    for item in items {
        let row = [
            item.timestamp.ISO8601Format(),
            item.title.replacingOccurrences(of: ",", with: ";"),
            (item.notes ?? "").replacingOccurrences(of: ",", with: ";"),
            item.priority.displayName,
            item.isCompleted ? "Yes" : "No"
        ].joined(separator: ",")
        
        csv += row + "\n"
    }
    
    return csv
}
```

### Data Import

#### Import from JSON

```swift
func importFromJSON(_ jsonString: String) throws {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    let importedItems = try decoder.decode([Item].self, from: jsonString.data(using: .utf8)!)
    
    for item in importedItems {
        modelContext.insert(item)
    }
}
```

### Statistics and Analytics

#### Item Statistics

```swift
struct ItemStatistics {
    let totalItems: Int
    let itemsToday: Int
    let itemsThisWeek: Int
    let averageItemsPerDay: Double
    let mostActiveHour: Int
    
    init(from items: [Item]) {
        totalItems = items.count
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        itemsToday = items.filter { $0.timestamp >= startOfDay }.count
        itemsThisWeek = items.filter { $0.timestamp >= startOfWeek }.count
        
        if let firstItem = items.first {
            let daysSinceFirst = calendar.dateComponents([.day], from: firstItem.timestamp, to: now).day ?? 1
            averageItemsPerDay = Double(totalItems) / Double(daysSinceFirst)
        } else {
            averageItemsPerDay = 0
        }
        
        let hourCounts = Dictionary(grouping: items) { item in
            calendar.component(.hour, from: item.timestamp)
        }.mapValues { $0.count }
        
        mostActiveHour = hourCounts.max(by: { $0.value < $1.value })?.key ?? 0
    }
}
```

#### Statistics View

```swift
struct StatisticsView: View {
    let statistics: ItemStatistics
    
    var body: some View {
        List {
            Section("Overview") {
                StatRow(title: "Total Items", value: "\(statistics.totalItems)")
                StatRow(title: "Items Today", value: "\(statistics.itemsToday)")
                StatRow(title: "Items This Week", value: "\(statistics.itemsThisWeek)")
            }
            
            Section("Analytics") {
                StatRow(title: "Average per Day", value: String(format: "%.1f", statistics.averageItemsPerDay))
                StatRow(title: "Most Active Hour", value: "\(statistics.mostActiveHour):00")
            }
        }
        .navigationTitle("Statistics")
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
    }
}
```

---

## Testing Examples

### Model Testing

#### Basic Model Tests

```swift
struct ItemModelTests {
    
    @Test func testItemCreation() async throws {
        let timestamp = Date()
        let item = Item(timestamp: timestamp)
        
        #expect(item.timestamp == timestamp)
        #expect(item.title.isEmpty)
        #expect(item.notes == nil)
        #expect(item.priority == .medium)
        #expect(item.isCompleted == false)
    }
    
    @Test func testItemInitialization() async throws {
        let timestamp = Date()
        let title = "Test Item"
        let notes = "Test Notes"
        let priority = Priority.high
        
        let item = Item(timestamp: timestamp, title: title, notes: notes, priority: priority)
        
        #expect(item.timestamp == timestamp)
        #expect(item.title == title)
        #expect(item.notes == notes)
        #expect(item.priority == priority)
        #expect(item.isCompleted == false)
    }
}
```

#### Data Operations Testing

```swift
struct DataOperationsTests {
    
    @Test func testItemInsertion() async throws {
        // This would require a test ModelContainer
        // Implementation depends on testing framework setup
    }
    
    @Test func testItemDeletion() async throws {
        // Test deletion logic
    }
    
    @Test func testItemUpdate() async throws {
        let item = Item(timestamp: Date())
        let newTitle = "Updated Title"
        
        item.title = newTitle
        
        #expect(item.title == newTitle)
    }
}
```

### UI Testing

#### View Rendering Tests

```swift
struct ViewTests {
    
    @Test func testContentViewRenders() async throws {
        // Test that ContentView renders without crashing
    }
    
    @Test func testItemListDisplays() async throws {
        // Test that item list displays correctly
    }
}
```

### Integration Testing

#### End-to-End Tests

```swift
struct IntegrationTests {
    
    @Test func testCompleteWorkflow() async throws {
        // Test complete CRUD workflow
        // 1. Create item
        // 2. Verify it appears in list
        // 3. Update item
        // 4. Verify changes
        // 5. Delete item
        // 6. Verify removal
    }
}
```

---

## Performance Optimization

### Lazy Loading

#### Pagination Implementation

```swift
struct PaginatedItemList: View {
    @State private var currentPage = 0
    @State private var isLoading = false
    let itemsPerPage = 20
    
    var displayedItems: [Item] {
        let startIndex = currentPage * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, items.count)
        return Array(items[startIndex..<endIndex])
    }
    
    var body: some View {
        List {
            ForEach(displayedItems) { item in
                ItemRow(item: item)
            }
            
            if hasMoreItems {
                Button("Load More") {
                    loadNextPage()
                }
                .disabled(isLoading)
            }
        }
    }
    
    private var hasMoreItems: Bool {
        (currentPage + 1) * itemsPerPage < items.count
    }
    
    private func loadNextPage() {
        currentPage += 1
    }
}
```

### Memory Management

#### Efficient Data Handling

```swift
// Use @Query with specific filters to avoid loading unnecessary data
@Query(filter: #Predicate<Item> { item in
    item.timestamp > Calendar.current.date(byAdding: .day, value: -7, to: Date())!
}, sort: [SortDescriptor(\Item.timestamp, order: .reverse)]) 
private var recentItems: [Item]

// Clear old data periodically
func cleanupOldData() {
    let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    
    for item in items where item.timestamp < oneMonthAgo {
        modelContext.delete(item)
    }
}
```

---

## Error Handling

### Graceful Error Handling

#### Database Operation Errors

```swift
func safeAddItem() {
    do {
        let newItem = Item(timestamp: Date())
        modelContext.insert(newItem)
        try modelContext.save()
    } catch {
        print("Failed to add item: \(error)")
        // Show user-friendly error message
        showError("Failed to add item. Please try again.")
    }
}

func safeDeleteItems(_ offsets: IndexSet) {
    do {
        for index in offsets {
            modelContext.delete(items[index])
        }
        try modelContext.save()
    } catch {
        print("Failed to delete items: \(error)")
        showError("Failed to delete items. Please try again.")
    }
}
```

#### User Feedback

```swift
@State private var showingError = false
@State private var errorMessage = ""

func showError(_ message: String) {
    errorMessage = message
    showingError = true
}

// In your view
.alert("Error", isPresented: $showingError) {
    Button("OK") { }
} message: {
    Text(errorMessage)
}
```

This comprehensive usage examples document provides practical guidance for developers working with the BabySteps application, from basic operations to advanced features and best practices.