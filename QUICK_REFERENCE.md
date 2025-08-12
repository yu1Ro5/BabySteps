# BabySteps Quick Reference

A concise reference guide for all public APIs, functions, and components in the BabySteps iOS application.

## Core Components

### BabyStepsApp
- **File**: `BabySteps/BabyStepsApp.swift`
- **Type**: `@main struct BabyStepsApp: App`
- **Purpose**: Main app entry point and SwiftData configuration

**Key Properties**:
```swift
var sharedModelContainer: ModelContainer
```

**Key Methods**:
```swift
var body: some Scene
```

---

### ContentView
- **File**: `BabySteps/ContentView.swift`
- **Type**: `struct ContentView: View`
- **Purpose**: Main view with CRUD operations

**Key Properties**:
```swift
@Environment(\.modelContext) private var modelContext
@Query private var items: [Item]
```

**Key Methods**:
```swift
private func addItem()
private func deleteItems(offsets: IndexSet)
```

---

### Item Model
- **File**: `BabySteps/Item.swift`
- **Type**: `@Model final class Item`
- **Purpose**: Data model for timestamped items

**Key Properties**:
```swift
var timestamp: Date
```

**Key Methods**:
```swift
init(timestamp: Date)
```

---

## SwiftData Operations

### Basic CRUD

**Create**:
```swift
let newItem = Item(timestamp: Date())
modelContext.insert(newItem)
```

**Read**:
```swift
@Query private var items: [Item]
```

**Update**:
```swift
item.timestamp = newDate
// Changes are automatically saved
```

**Delete**:
```swift
modelContext.delete(item)
```

---

### Query Examples

**All Items**:
```swift
@Query private var items: [Item]
```

**Filtered Items**:
```swift
@Query(filter: #Predicate<Item> { item in
    item.timestamp > yesterday
}) private var recentItems: [Item]
```

**Sorted Items**:
```swift
@Query(sort: [SortDescriptor(\Item.timestamp, order: .reverse)]) 
private var sortedItems: [Item]
```

---

## UI Components

### Navigation
```swift
NavigationSplitView {
    // Master view (list)
} detail: {
    // Detail view
}
```

### Lists
```swift
List {
    ForEach(items) { item in
        NavigationLink {
            // Detail view
        } label: {
            // Row content
        }
    }
    .onDelete(perform: deleteItems)
}
```

### Toolbars
```swift
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        EditButton()
    }
    ToolbarItem {
        Button(action: addItem) {
            Label("Add Item", systemImage: "plus")
        }
    }
}
```

---

## Common Patterns

### Adding Items
```swift
private func addItem() {
    withAnimation {
        let newItem = Item(timestamp: Date())
        modelContext.insert(newItem)
    }
}
```

### Deleting Items
```swift
private func deleteItems(offsets: IndexSet) {
    withAnimation {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}
```

### Preview Setup
```swift
#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
```

---

## Environment Variables

### Model Context
```swift
@Environment(\.modelContext) private var modelContext
```

### Query
```swift
@Query private var items: [Item]
```

---

## Error Handling

### Fatal Errors
```swift
fatalError("Could not create ModelContainer: \(error)")
```

### Safe Operations
```swift
do {
    try modelContext.save()
} catch {
    print("Operation failed: \(error)")
}
```

---

## Testing

### Test Structure
```swift
struct BabyStepsTests {
    @Test func example() async throws {
        // Test implementation
    }
}
```

### Test Examples
```swift
@Test func testItemCreation() async throws {
    let timestamp = Date()
    let item = Item(timestamp: timestamp)
    #expect(item.timestamp == timestamp)
}
```

---

## File Structure

```
BabySteps/
├── BabyStepsApp.swift      # Main app entry point
├── ContentView.swift       # Main view
├── Item.swift             # Data model
└── Assets.xcassets/       # App assets

BabyStepsTests/
└── BabyStepsTests.swift   # Unit tests

BabyStepsUITests/           # UI tests
```

---

## Requirements

- **iOS**: 17.0+
- **Xcode**: 15.0+
- **Swift**: 5.9+
- **Frameworks**: SwiftUI, SwiftData, Foundation

---

## Common Issues & Solutions

### Build Errors
- Ensure iOS 17.0+ target
- Verify Xcode 15.0+
- Check SwiftData import

### Runtime Crashes
- Verify SwiftData schema configuration
- Check model context injection
- Ensure main thread usage

### Data Not Persisting
- Verify `isStoredInMemoryOnly: false`
- Check schema includes all models
- Ensure proper error handling

---

## Quick Commands

### Xcode
```bash
# Open project
open BabySteps.xcodeproj

# Build and run
Cmd + R

# Clean build folder
Cmd + Shift + K
```

### Terminal
```bash
# List project files
ls -la

# Check Swift version
swift --version

# Check Xcode version
xcodebuild -version
```

---

## Extension Points

### Adding New Models
1. Create `@Model` class
2. Add to schema in `BabyStepsApp.swift`
3. Create corresponding views

### Adding New Features
- Search: Implement `@Query` with predicates
- Sorting: Add sort descriptors
- Filtering: Use SwiftData predicates
- Relationships: Define model relationships

---

## Performance Tips

- Use `@Query` for automatic updates
- Implement pagination for large datasets
- Use `withAnimation` for smooth transitions
- Leverage SwiftData's automatic memory management

---

## Security Notes

- Data stored locally on device
- No network transmission
- SwiftData handles encryption
- Validate user inputs

---

## Support Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata/)
- [iOS Development Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

## Version History

- **v1.0**: Initial release with basic CRUD operations
- **Future**: Search, sorting, filtering, and advanced features

---

*This quick reference covers the essential APIs and patterns. For detailed documentation, see `README.md`, `API_REFERENCE.md`, and `USAGE_EXAMPLES.md`.*