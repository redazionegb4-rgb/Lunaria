import SwiftUI

extension Color {
    static let lunariaPink = Color(red: 0.97, green: 0.33, blue: 0.57)
    static let lunariaViolet = Color(red: 0.53, green: 0.35, blue: 0.96)
    static let lunariaBlue = Color(red: 0.30, green: 0.68, blue: 1.00)
}

struct LiquidBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.lunariaViolet.opacity(0.28), Color.lunariaPink.opacity(0.20), Color.lunariaBlue.opacity(0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.lunariaPink.opacity(0.22))
                .frame(width: 280, height: 280)
                .blur(radius: 35)
                .offset(x: 130, y: -260)

            Circle()
                .fill(Color.lunariaBlue.opacity(0.20))
                .frame(width: 240, height: 240)
                .blur(radius: 40)
                .offset(x: -150, y: 310)
        }
    }
}

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(.white.opacity(0.28), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.08), radius: 20, y: 10)
    }
}

struct GradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [Color.lunariaPink, Color.lunariaViolet], startPoint: .leading, endPoint: .trailing),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
    }
}
