# BabySteps API Reference

This document provides comprehensive technical documentation for all public APIs, functions, and components in the BabySteps iOS application.

## Table of Contents

1. [BabyStepsApp](#babystepsapp)
2. [ContentView](#contentview)
3. [Item Model](#item-model)
4. [SwiftData Integration](#swiftdata-integration)
5. [Testing Framework](#testing-framework)

---

## BabyStepsApp

**File**: `BabySteps/BabyStepsApp.swift`  
**Type**: `@main struct`  
**Inheritance**: `App`  
**Framework**: SwiftUI

### Declaration

```swift
@main
struct BabyStepsApp: App
```

### Description

The main application entry point that configures the SwiftData container and sets up the app structure. This struct conforms to the `App` protocol and serves as the root of the application hierarchy.

### Properties

#### `sharedModelContainer: ModelContainer`

**Type**: `ModelContainer`  
**Access Level**: `internal`  
**Description**: A shared SwiftData container configured with the application's data schema.

**Configuration Details**:
- **Schema**: Includes `Item.self` model
- **Storage**: Persistent storage (`isStoredInMemoryOnly: false`)
- **Error Handling**: Fatal error on container creation failure

**Usage Example**:
```swift
@Environment(\.modelContext) private var modelContext
// modelContext is automatically injected from sharedModelContainer
```

### Methods

#### `body: some Scene`

**Return Type**: `some Scene`  
**Description**: Defines the app's scene structure and view hierarchy.

**Implementation**:
```swift
var body: some Scene {
    WindowGroup {
        ContentView()
    }
    .modelContainer(sharedModelContainer)
}
```

**Dependencies**:
- `ContentView`: Main view of the application
- `sharedModelContainer`: SwiftData container for data persistence

### Initialization

The `sharedModelContainer` is initialized using a computed property that:

1. Creates a schema with the `Item` model
2. Configures persistent storage
3. Creates and returns a `ModelContainer` instance
4. Handles initialization errors with fatal error

**Error Handling**:
```swift
do {
    return try ModelContainer(for: schema, configurations: [modelConfiguration])
} catch {
    fatalError("Could not create ModelContainer: \(error)")
}
```

---

## ContentView

**File**: `BabySteps/ContentView.swift`  
**Type**: `struct`  
**Inheritance**: `View`  
**Framework**: SwiftUI

### Declaration

```swift
struct ContentView: View
```

### Description

The main view that displays the list of items and provides CRUD operations. This view serves as the primary interface for user interaction with the application's data.

### Properties

#### `@Environment(\.modelContext) private var modelContext`

**Type**: `ModelContext`  
**Access Level**: `private`  
**Description**: SwiftData model context for database operations.

**Usage**:
- Insert new items: `modelContext.insert(newItem)`
- Delete items: `modelContext.delete(item)`
- Save changes: `try modelContext.save()`

#### `@Query private var items: [Item]`

**Type**: `[Item]`  
**Access Level**: `private`  
**Description**: Observable query for fetching all items from the database.

**Behavior**:
- Automatically updates when database changes
- Provides real-time data synchronization
- Manages memory automatically

### Methods

#### `addItem()`

**Access Level**: `private`  
**Return Type**: `Void`  
**Description**: Creates and inserts a new item with the current timestamp.

**Implementation**:
```swift
private func addItem() {
    withAnimation {
        let newItem = Item(timestamp: Date())
        modelContext.insert(newItem)
    }
}
```

**Parameters**: None  
**Side Effects**: 
- Creates new `Item` instance
- Inserts item into database
- Triggers UI update via `@Query`

**Usage**: Called when the user taps the "+" button in the toolbar.

#### `deleteItems(offsets: IndexSet)`

**Access Level**: `private`  
**Return Type**: `Void`  
**Description**: Deletes items at the specified indices.

**Implementation**:
```swift
private func deleteItems(offsets: IndexSet) {
    withAnimation {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}
```

**Parameters**:
- `offsets: IndexSet` - The indices of items to delete

**Side Effects**:
- Removes items from database
- Triggers UI update via `@Query`
- Animates deletion with `withAnimation`

**Usage**: Called when the user swipes to delete items or uses the edit mode.

### UI Components

#### NavigationSplitView

**Type**: `NavigationSplitView`  
**Description**: Provides a master-detail interface for the application.

**Structure**:
- **Master**: List of items with navigation
- **Detail**: Item detail view or placeholder

#### List

**Type**: `List`  
**Description**: Displays items with navigation links and swipe-to-delete functionality.

**Features**:
- `ForEach(items)` iteration over data
- `NavigationLink` for item details
- `.onDelete(perform: deleteItems)` for deletion

#### Toolbar

**Type**: `Toolbar`  
**Description**: Contains action buttons for the view.

**Items**:
- `EditButton()`: Toggles edit mode
- `Button(action: addItem)`: Adds new items

#### NavigationLink

**Type**: `NavigationLink`  
**Description**: Links to item detail views.

**Current Implementation**:
```swift
NavigationLink {
    Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
} label: {
    Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
}
```

### Preview Support

**File**: `ContentView.swift` (bottom of file)

```swift
#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
```

**Configuration**:
- Uses in-memory container for previews
- Isolates preview data from production data
- Enables SwiftUI previews in Xcode

---

## Item Model

**File**: `BabySteps/Item.swift`  
**Type**: `@Model final class`  
**Framework**: SwiftData

### Declaration

```swift
@Model
final class Item
```

### Description

A SwiftData model representing a timestamped item in the application. This class is marked with `@Model` to enable SwiftData persistence and `final` for performance optimization.

### Properties

#### `timestamp: Date`

**Type**: `Date`  
**Access Level**: `internal`  
**Description**: The creation timestamp of the item.

**Usage**:
- Display in UI: `Text(item.timestamp, format: .dateTime)`
- Sorting: `items.sorted { $0.timestamp > $1.timestamp }`
- Filtering: `items.filter { $0.timestamp > yesterday }`

### Initializer

#### `init(timestamp: Date)`

**Access Level**: `internal`  
**Description**: Creates a new Item instance with the specified timestamp.

**Parameters**:
- `timestamp: Date` - The timestamp to assign to the item

**Usage**:
```swift
let newItem = Item(timestamp: Date())
let customItem = Item(timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
```

### SwiftData Integration

**Persistence**: Automatically persisted to device storage  
**Observability**: Changes trigger UI updates via `@Query`  
**Relationships**: Can be extended with relationships to other models  
**Migration**: Supports automatic schema migration

---

## SwiftData Integration

### ModelContainer Configuration

**Location**: `BabyStepsApp.swift`

```swift
let schema = Schema([
    Item.self,
])
let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
```

**Configuration Options**:
- `isStoredInMemoryOnly: false` - Enables persistent storage
- `schema` - Defines the data model structure
- `configurations` - Array of configuration options

### ModelContext Usage

**Injection**: Automatically injected via `.modelContainer()` modifier  
**Thread Safety**: Must be used on main thread  
**Lifecycle**: Managed by SwiftUI view lifecycle

**Common Operations**:
```swift
// Insert
modelContext.insert(newItem)

// Delete
modelContext.delete(item)

// Save (optional, automatic in most cases)
try modelContext.save()

// Fetch (handled by @Query)
@Query private var items: [Item]
```

### Query System

**Property Wrapper**: `@Query`  
**Automatic Updates**: UI automatically reflects data changes  
**Memory Management**: Automatic memory management

**Advanced Queries** (future extensions):
```swift
@Query(filter: #Predicate<Item> { item in
    item.timestamp > yesterday
}, sort: \Item.timestamp) private var recentItems: [Item]
```

---

## Testing Framework

### Test Structure

**File**: `BabyStepsTests/BabyStepsTests.swift`  
**Framework**: Testing (iOS 17+)

### Test Class

```swift
struct BabyStepsTests {
    @Test func example() async throws {
        // Test implementation
    }
}
```

### Testing Capabilities

**Data Model Testing**:
- Model creation and validation
- Property access and modification
- Initializer behavior

**CRUD Operations Testing**:
- Insert operations
- Query operations
- Delete operations
- Update operations

**UI Testing**:
- View rendering
- User interactions
- Data binding

**Integration Testing**:
- SwiftData operations
- View-model communication
- Data persistence

### Test Examples

**Model Creation Test**:
```swift
@Test func testItemCreation() async throws {
    let timestamp = Date()
    let item = Item(timestamp: timestamp)
    
    #expect(item.timestamp == timestamp)
}
```

**Data Persistence Test**:
```swift
@Test func testDataPersistence() async throws {
    // Test data persistence logic
}
```

---

## Error Handling

### Fatal Errors

**Location**: `BabyStepsApp.swift`

```swift
fatalError("Could not create ModelContainer: \(error)")
```

**When**: ModelContainer creation fails  
**Impact**: App crashes with descriptive error message  
**Mitigation**: Ensure proper SwiftData configuration

### Runtime Errors

**SwiftData Operations**: Use `try-catch` blocks  
**UI Updates**: Handle animation and state changes gracefully  
**Data Validation**: Validate data before database operations

---

## Performance Considerations

### Memory Management

- `@Query` automatically manages memory
- Items are loaded on-demand
- Unused data is automatically cleaned up

### Database Operations

- Batch operations for multiple items
- Use `withAnimation` for smooth UI updates
- Consider pagination for large datasets

### UI Performance

- SwiftUI automatically optimizes view updates
- Use `@State` and `@Binding` appropriately
- Minimize unnecessary view redraws

---

## Security Considerations

### Data Access

- All data is stored locally on device
- No network transmission of user data
- SwiftData handles data encryption automatically

### Input Validation

- Validate timestamps before creation
- Sanitize user inputs (future extensions)
- Implement proper error handling

---

## Future Extensions

### Planned Features

1. **Search Functionality**: Implement search with predicates
2. **Sorting Options**: Add multiple sort criteria
3. **Data Export**: Export data to various formats
4. **Cloud Sync**: iCloud integration for data backup
5. **Advanced Filtering**: Date range and custom filters

### API Extensions

```swift
// Search functionality
@Query(filter: #Predicate<Item> { item in
    item.timestamp.description.localizedStandardContains(searchText)
}) private var searchResults: [Item]

// Sorting
@Query(sort: [SortDescriptor(\Item.timestamp, order: .reverse)]) 
private var sortedItems: [Item]
```

---

## Version Compatibility

### iOS Version Support

- **Minimum**: iOS 17.0
- **Target**: iOS 17.0+
- **Swift**: 5.9+

### Xcode Requirements

- **Minimum**: Xcode 15.0
- **Recommended**: Latest Xcode version
- **SwiftUI**: 5.0+

### Framework Dependencies

- **SwiftUI**: Built-in iOS framework
- **SwiftData**: iOS 17.0+ framework
- **Foundation**: Built-in iOS framework