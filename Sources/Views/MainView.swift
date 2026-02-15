import SwiftData
import SwiftUI

/// タブ切り替えを管理し、単一のボトムバーでフィルター・タブ・新規追加を提供する。
struct MainView: View {
    @State private var selectedTab: AppTab = .tasks
    @State private var selectedFilter: TaskFilter = .all
    @State private var showingAddTask = false

    var body: some View {
        Group {
            if selectedTab == .tasks {
                TaskListView(selectedFilter: $selectedFilter)
            }
            else {
                ActivityView()
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskSheetView(isPresented: $showingAddTask)
        }
        .safeAreaInset(edge: .bottom) {
            mainBottomBar
        }
    }

    /// 共通ボトムバー：フィルター | タブ切り替え | 新規追加
    private var mainBottomBar: some View {
        HStack(spacing: 0) {
            // 左下：フィルター
            Menu {
                Picker("フィルター", selection: $selectedFilter) {
                    ForEach(TaskFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title2)
            }
            .frame(width: 44, height: 44)

            Spacer()

            // 中央：タブ切り替え
            HStack(spacing: 0) {
                TabBarButton(selectedTab: $selectedTab, tab: .tasks, icon: "list.bullet", label: "タスク")
                TabBarButton(selectedTab: $selectedTab, tab: .activity, icon: "chart.bar.fill", label: "アクティビティ")
            }

            Spacer()

            // 右下：新規タスク追加
            Button(action: { showingAddTask = true }) {
                Image(systemName: "square.and.pencil")
                    .font(.title2)
            }
            .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(.bar)
    }
}
