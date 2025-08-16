import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
                .tag(0)
            
            FeaturesView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("機能")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("設定")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("BabySteps")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("SwiftUIベースのiOSアプリケーション")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 15) {
                    FeatureRow(icon: "swift", title: "SwiftUI", description: "モダンなUIフレームワーク")
                    FeatureRow(icon: "gear", title: "XcodeGen", description: "自動プロジェクト生成")
                    FeatureRow(icon: "arrow.triangle.2.circlepath", title: "CI/CD", description: "GitHub Actions自動化")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            .navigationTitle("ホーム")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct FeaturesView: View {
    let features = [
        ("swift", "SwiftUI", "最新のSwiftUIフレームワークを使用"),
        ("gear", "XcodeGen", "プロジェクトファイルの自動生成"),
        ("arrow.triangle.2.circlepath", "CI/CD", "GitHub Actionsによる自動化"),
        ("iphone", "iOS 18.0+", "最新のiOS機能をサポート"),
        ("checkmark.circle", "テスト対応", "ユニットテストの実行環境"),
        ("markdown", "Markdown", "Markdownファイルの自動チェック")
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(features, id: \.0) { feature in
                    FeatureRow(icon: feature.0, title: feature.1, description: feature.2)
                }
            }
            .navigationTitle("機能")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var selectedLanguage = "日本語"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("通知")) {
                    Toggle("通知を有効にする", isOn: $notificationsEnabled)
                }
                
                Section(header: Text("外観")) {
                    Toggle("ダークモード", isOn: $darkModeEnabled)
                    Picker("言語", selection: $selectedLanguage) {
                        Text("日本語").tag("日本語")
                        Text("English").tag("English")
                    }
                }
                
                Section(header: Text("アプリ情報")) {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("ビルド番号")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("サポート")) {
                    Button("フィードバックを送信") {
                        // フィードバック機能の実装
                    }
                    
                    Button("プライバシーポリシー") {
                        // プライバシーポリシーの表示
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
