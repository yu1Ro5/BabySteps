import SwiftUI

struct SecondTabView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "star.circle")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Coming Soon")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("このタブには後で機能が追加される予定です")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("機能予定")
        }
    }
}

#Preview {
    SecondTabView()
}
