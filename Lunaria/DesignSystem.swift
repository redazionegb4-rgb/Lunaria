import SwiftUI

extension Color {
    static let lunaInk = Color(red: 0.18, green: 0.08, blue: 0.22)
    static let lunaBerry = Color(red: 0.77, green: 0.16, blue: 0.42)
    static let lunaBlush = Color(red: 1.00, green: 0.43, blue: 0.55)
    static let lunaLilac = Color(red: 0.61, green: 0.42, blue: 0.88)
    static let lunaMist = Color(red: 0.98, green: 0.94, blue: 0.97)
}

struct AuraBackground: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            LinearGradient(
                colors: [Color.lunaMist, Color.lunaBlush.opacity(0.10), Color.lunaLilac.opacity(0.11)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
            Circle().fill(Color.lunaBlush.opacity(0.22)).frame(width: 360, height: 360).blur(radius: 75).offset(x: 190, y: -330)
            Circle().fill(Color.lunaLilac.opacity(0.17)).frame(width: 330, height: 330).blur(radius: 80).offset(x: -190, y: 330)
        }
    }
}

struct FrostCard<Content: View>: View {
    var radius: CGFloat = 28
    var padding: CGFloat = 20
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(LinearGradient(colors: [.white.opacity(0.85), .white.opacity(0.18)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
            }
            .shadow(color: Color.lunaInk.opacity(0.09), radius: 24, y: 12)
    }
}

struct PrimaryLunaButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [Color.lunaBlush, Color.lunaBerry, Color.lunaLilac], startPoint: .leading, endPoint: .trailing),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .shadow(color: Color.lunaBerry.opacity(0.24), radius: 16, y: 8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct LunaBadge: View {
    let title: String
    let icon: String
    var tint: Color = .lunaBerry

    var body: some View {
        Label(title, systemImage: icon)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(tint.opacity(0.11), in: Capsule())
    }
}

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.title3.bold())
            if let subtitle { Text(subtitle).font(.subheadline).foregroundStyle(.secondary) }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}
