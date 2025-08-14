import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.pink)
                
                Text("BabySteps")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Welcome to your baby's journey")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                VStack(spacing: 15) {
                    NavigationLink(destination: MilestoneView()) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Milestones")
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: GrowthView()) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(.green)
                            Text("Growth Tracking")
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: MemoriesView()) {
                        HStack {
                            Image(systemName: "photo.fill")
                                .foregroundColor(.blue)
                            Text("Memories")
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}