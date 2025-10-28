import SwiftUI

/// iOS 26のLiquid Glassデザインシステムを実装するカスタムビューモディファイア
struct LiquidGlassModifier: ViewModifier {
    let intensity: Double
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    
    init(intensity: Double = 0.1, cornerRadius: CGFloat = 16, borderWidth: CGFloat = 1) {
        self.intensity = intensity
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .opacity(intensity)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.2),
                                        .clear,
                                        .white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: borderWidth
                            )
                    )
                    .shadow(
                        color: .black.opacity(0.1),
                        radius: 10,
                        x: 0,
                        y: 5
                    )
            )
    }
}

/// Liquid Glassデザインを簡単に適用するためのViewExtension
extension View {
    /// Liquid Glassデザインを適用します
    /// - Parameters:
    ///   - intensity: ガラス効果の強度（0.0-1.0）
    ///   - cornerRadius: 角の丸み
    ///   - borderWidth: ボーダーの太さ
    func liquidGlass(
        intensity: Double = 0.1,
        cornerRadius: CGFloat = 16,
        borderWidth: CGFloat = 1
    ) -> some View {
        self.modifier(
            LiquidGlassModifier(
                intensity: intensity,
                cornerRadius: cornerRadius,
                borderWidth: borderWidth
            )
        )
    }
}

/// Liquid Glass背景用のカスタム背景ビュー
struct LiquidGlassBackground: View {
    var body: some View {
        ZStack {
            // ベースグラデーション
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemBackground).opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // ガラス質感のオーバーレイ
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.3)
        }
        .ignoresSafeArea()
    }
}

/// Liquid Glassカード用のカスタムビュー
struct LiquidGlassCard<Content: View>: View {
    let content: Content
    let intensity: Double
    let cornerRadius: CGFloat
    let padding: CGFloat
    
    init(
        intensity: Double = 0.15,
        cornerRadius: CGFloat = 20,
        padding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.intensity = intensity
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .opacity(intensity)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.3),
                                        .clear,
                                        .white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: .black.opacity(0.05),
                        radius: 20,
                        x: 0,
                        y: 10
                    )
                    .shadow(
                        color: .black.opacity(0.1),
                        radius: 5,
                        x: 0,
                        y: 2
                    )
            )
    }
}

#Preview {
    ZStack {
        LiquidGlassBackground()
        
        VStack(spacing: 20) {
            LiquidGlassCard {
                VStack {
                    Text("Liquid Glass Card")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("美しいガラス質感のカード")
                        .foregroundColor(.secondary)
                }
            }
            
            Text("通常のテキスト")
                .liquidGlass(intensity: 0.1, cornerRadius: 12)
                .padding()
        }
        .padding()
    }
}