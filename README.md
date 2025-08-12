# BabySteps

A SwiftUI iOS application that demonstrates basic CRUD operations using SwiftData for persistent storage.

## Overview

BabySteps is a simple iOS application built with SwiftUI and SwiftData that allows users to create, read, and delete timestamped items. It serves as a foundation for learning SwiftUI data management patterns and can be extended for more complex applications.

## Architecture

The application follows the MVVM (Model-View-ViewModel) pattern with SwiftData integration:

- **Model Layer**: SwiftData models for data persistence
- **View Layer**: SwiftUI views for the user interface
- **Data Layer**: SwiftData ModelContainer for database management

## Public APIs and Components

### 1. BabyStepsApp

**File**: `BabySteps/BabyStepsApp.swift`

The main application entry point that configures the SwiftData container and sets up the app structure.

#### Properties

- `sharedModelContainer: ModelContainer` - A shared SwiftData container configured with the application's data schema

#### Usage

```swift
@main
struct BabyStepsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

#### Configuration

The app is configured with:
- **Schema**: Includes the `Item` model for data persistence
- **Storage**: Persistent storage (not in-memory only)
- **Model Container**: Automatically injected into the view hierarchy

### 2. ContentView

**File**: `BabySteps/ContentView.swift`

The main view that displays the list of items and provides CRUD operations.

#### Properties

- `@Environment(\.modelContext) private var modelContext` - SwiftData model context for database operations
- `@Query private var items: [Item]` - Observable query for fetching all items from the database

#### Public Methods

##### `addItem()`
Creates and inserts a new item with the current timestamp.

```swift
private func addItem() {
    withAnimation {
        let newItem = Item(timestamp: Date())
        modelContext.insert(newItem)
    }
}
```

**Usage**: Called when the user taps the "+" button in the toolbar.

##### `deleteItems(offsets: IndexSet)`
Deletes items at the specified indices.

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

**Usage**: Called when the user swipes to delete items or uses the edit mode.

#### UI Components

- **NavigationSplitView**: Provides a master-detail interface
- **List**: Displays items with navigation links
- **Toolbar**: Contains add and edit buttons
- **NavigationLink**: Links to item detail views

#### Preview Support

```swift
#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
```

### 3. Item Model

**File**: `BabySteps/Item.swift`

A SwiftData model representing a timestamped item in the application.

#### Properties

- `timestamp: Date` - The creation timestamp of the item

#### Initializer

```swift
init(timestamp: Date)
```

**Parameters**:
- `timestamp: Date` - The timestamp to assign to the item

#### Usage Examples

**Creating a new item**:
```swift
let newItem = Item(timestamp: Date())
modelContext.insert(newItem)
```

**Fetching items**:
```swift
@Query private var items: [Item]
```

**Deleting an item**:
```swift
modelContext.delete(item)
```

## Data Flow

1. **Data Creation**: User taps "+" button → `addItem()` is called → New `Item` is created and inserted into the database
2. **Data Display**: `@Query` automatically observes the database → UI updates when data changes
3. **Data Deletion**: User swipes to delete → `deleteItems()` is called → Items are removed from the database

## SwiftData Integration

The application uses SwiftData for:
- **Persistence**: Data is stored locally on the device
- **Observability**: Automatic UI updates when data changes
- **Querying**: Simple data fetching with `@Query` property wrapper
- **Transactions**: Automatic transaction management for data operations

## Testing

**File**: `BabyStepsTests/BabyStepsTests.swift`

The project includes a basic testing structure using the Testing framework. Tests can be written to verify:

- Data model creation and validation
- CRUD operations
- UI interactions
- Data persistence

## Extending the Application

### Adding New Models

1. Create a new Swift file with a `@Model` class
2. Add the model to the schema in `BabyStepsApp.swift`
3. Create corresponding views and CRUD operations

### Adding New Features

- **Search**: Implement `@Query` with predicates
- **Sorting**: Add sort descriptors to queries
- **Filtering**: Use SwiftData predicates for data filtering
- **Relationships**: Define relationships between models

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Dependencies

- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Persistent data framework
- **Foundation**: Basic iOS functionality

## Project Structure

```
BabySteps/
├── BabyStepsApp.swift      # Main app entry point
├── ContentView.swift       # Main view with CRUD operations
├── Item.swift             # Data model
├── Assets.xcassets/       # App assets
└── BabySteps.xcodeproj/   # Xcode project file

BabyStepsTests/
└── BabyStepsTests.swift   # Unit tests

BabyStepsUITests/           # UI tests (empty)
```

## Getting Started

1. Open `BabySteps.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run the project
4. Use the "+" button to add items
5. Swipe left on items to delete them
6. Tap items to view details

## Best Practices

- **Data Operations**: Always perform database operations within the main thread
- **Error Handling**: Implement proper error handling for database operations
- **Memory Management**: Use `@Query` for automatic memory management
- **UI Updates**: Leverage SwiftData's automatic UI updates

## Troubleshooting

### Common Issues

1. **Build Errors**: Ensure you're using iOS 17.0+ and Xcode 15.0+
2. **Runtime Crashes**: Check that the SwiftData schema is properly configured
3. **Data Not Persisting**: Verify the `isStoredInMemoryOnly` setting is `false`

### Debug Tips

- Use Xcode's SwiftData inspector to view database contents
- Check the console for SwiftData-related logs
- Verify model context is properly injected into views

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is available under the MIT License. See the LICENSE file for details.

## Support

For questions or issues:
1. Check the troubleshooting section
2. Review SwiftData and SwiftUI documentation
3. Open an issue in the project repository