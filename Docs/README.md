# BabySteps アプリ ドキュメント

## 📱 アプリ概要

BabyStepsは、完了ではなく着手回数を記録するToDoアプリです。継続が苦手な人や、やらなきゃいけないことをやらない人向けに、小さな一歩を積み重ねる喜びを提供します。

## 🎯 コンセプト

従来のToDoアプリは「完了」を重視しますが、BabyStepsは「着手」を重視します。これにより：

- 完璧を求めず、小さな一歩から始められる
- 継続の喜びを実感できる
- 習慣化しやすい環境を提供する

## 📚 ドキュメント構成

### 1. [Functional Design](./functional-design.md)

Defines the overall app concept and functional requirements.

**Main Contents:**

- App overview and concept
- Core features (task management, attempt recording, completion management)
- Display and UI features
- Development phases and success metrics

### 2. [UI Design](./ui-design.md)

Describes the layout and UI/UX design of each screen in detail.

**Main Contents:**

- Screen composition and navigation
- Detailed layout for each screen
- Color themes and animations
- Responsive design

### 3. [Database Design](./database-design.md)

Defines the data structure and data access layer using SwiftData.

**Main Contents:**

- Entity design (Task, Attempt)
- Database schema
- Data access using Repository pattern
- Performance optimization

## 🚀 主要機能

### Task Management

- Create, edit, and delete tasks
- Categorize by type (habit, project, learning, other)
- Set priority levels (low, medium, high)

### Attempt Recording

- One-tap attempt recording
- Count attempt frequency
- Display attempt history

### Statistics & Analysis

- Daily, weekly, monthly attempt counts
- Track consecutive days
- Category-based statistics

### Calendar View

- Visualize daily attempt records
- Track progress status

## 🛠 Technical Specifications

- **Platform**: iOS 18.0+
- **Framework**: SwiftUI + SwiftData
- **Architecture**: MVVM
- **Data Storage**: Local only (SwiftData)

## 📱 Screen Structure

1. **Task List** (Main screen)
2. **Statistics & Analysis**
3. **Calendar**
4. **Settings**

## 🔄 Development Phases

### Phase 1 (MVP)

- Basic task management
- Attempt recording functionality
- Completion management
- Basic statistics display

### Phase 2

- Calendar display
- Detailed statistics and analysis
- UI/UX improvements

### Phase 3

- iCloud synchronization
- Notification functionality
- Data export

## 💡 Design Principles

### Usability

- One-tap attempt recording
- Intuitive UI/UX
- Visual feedback to encourage continuation

### Performance

- Fast data access with SwiftData
- Efficient query design
- Proper index configuration

### Extensibility

- Modular design
- Consider future feature additions
- Prepare for iCloud synchronization

## 🤝 For Development Team

### Development Environment

- Xcode 16.4 (GitHub Actions
  compatible)
- iOS 18.0+ SDK
- Swift 6.0+

### Coding Standards

- SwiftLint compliance
- Strict MVVM pattern implementation
- Proper error handling

### Testing

- Unit tests
- UI tests
- Performance tests

## 📞 Support

For questions about the documentation or improvement suggestions,
please contact the development team.

---

**BabySteps** - 小さな一歩から大きな変化へ 🚀
