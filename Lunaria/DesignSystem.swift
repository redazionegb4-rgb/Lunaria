import SwiftUI

extension Color {
    static let lunariaCoral = Color(red: 1.00, green: 0.34, blue: 0.48)
    static let lunariaRose = Color(red: 0.92, green: 0.20, blue: 0.48)
    static let lunariaPlum = Color(red: 0.47, green: 0.20, blue: 0.58)
    static let lunariaCream = Color(red: 1.00, green: 0.97, blue: 0.96)
}

struct LiquidBackground: View {
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            LinearGradient(colors: [.lunariaCream, .lunariaCoral.opacity(0.10), .lunariaPlum.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            Circle().fill(Color.lunariaCoral.opacity(0.18)).frame(width: 320, height: 320).blur(radius: 55).offset(x: 150, y: -300)
            Circle().fill(Color.lunariaPlum.opacity(0.13)).frame(width: 300, height: 300).blur(radius: 60).offset(x: -170, y: 360)
        }
    }
}

struct GlassCard<Content: View>: View {
    let padding: CGFloat
    let content: Content
    init(padding: CGFloat = 18, @ViewBuilder content: () -> Content) { self.padding = padding; self.content = content() }
    var body: some View {
        content.padding(padding)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(.white.opacity(0.55), lineWidth: 1))
            .shadow(color: Color.lunariaPlum.opacity(0.10), radius: 24, y: 12)
    }
}

struct GradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.headline).foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
            .background(LinearGradient(colors: [.lunariaCoral, .lunariaRose, .lunariaPlum], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color.lunariaRose.opacity(0.25), radius: 14, y: 8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct StatusPill: View {
    let text: String
    let icon: String
    var body: some View { Label(text, systemImage: icon).font(.caption.weight(.semibold)).padding(.horizontal, 12).padding(.vertical, 8).background(.thinMaterial, in: Capsule()) }
}
