import SwiftUI

enum ActivityLevel: Int, CaseIterable {
    case none = 0      // 0件
    case low = 1       // 1-3件
    case medium = 2    // 4-6件
    case high = 3      // 7-9件
    case veryHigh = 4  // 10件以上
    
    var color: Color {
        switch self {
        case .none: return Color(hex: "#ebedf0")
        case .low: return Color(hex: "#a8e6b8")      // より明るい緑
        case .medium: return Color(hex: "#4cd46e")    // より明るい緑
        case .high: return Color(hex: "#3bb85a")      // より明るい緑
        case .veryHigh: return Color(hex: "#2a8a47")  // より明るい緑
        }
    }
}

// Color拡張でhexカラーをサポート
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
