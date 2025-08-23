import SwiftUI
import SwiftData

struct ActivityView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ActivityViewModel?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // カレンダーグリッド
                if let viewModel = viewModel {
                    CalendarGridView(activities: viewModel.dailyActivities)
                }
                
                // ローディング表示
                if viewModel?.isLoading == true {
                    ProgressView("アクティビティを読み込み中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // エラー表示
                if let errorMessage = viewModel?.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("アクティビティ")
            .onAppear {
                // ModelContextを使用してViewModelを作成
                viewModel = ActivityViewModel(modelContext: modelContext)
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
                // データベースの変更を検知してアクティビティを再読み込み
                viewModel?.refreshActivities()
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)) { _ in
                // オブジェクトの変更も検知してアクティビティを更新
                viewModel?.refreshActivities()
            }
        }
    }
    

}
