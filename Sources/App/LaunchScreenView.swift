import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                Text("BabySteps")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Every step counts")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
    }
}