import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: CycleStore
    @State private var page = 0
    @State private var name = ""
    @State private var lastStart = Date()
    @State private var cycleLength = 28
    @State private var periodLength = 5

    var body: some View {
        ZStack {
            AuraBackground()
            VStack(spacing: 0) {
                HStack { ForEach(0..<3) { index in Capsule().fill(index <= page ? Color.lunaBerry : Color.primary.opacity(0.10)).frame(height: 5) } }.padding(.horizontal, 24).padding(.top, 14)
                TabView(selection: $page) {
                    welcome.tag(0); profile.tag(1); cycle.tag(2)
                }.tabViewStyle(.page(indexDisplayMode: .never))
                Button(action: next) { Text(page == 2 ? "Inizia con Lunaria" : "Continua").frame(maxWidth: .infinity) }.buttonStyle(PrimaryLunaButtonStyle()).disabled(page == 1 && name.trimmingCharacters(in: .whitespaces).isEmpty).opacity(page == 1 && name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1).padding(22)
            }
        }
    }

    private var welcome: some View {
        VStack(spacing: 26) {
            Spacer()
            ZStack { Circle().fill(.ultraThinMaterial).frame(width: 210, height: 210).overlay(Circle().stroke(.white.opacity(0.8))); Image(systemName: "moon.stars.fill").font(.system(size: 86)).foregroundStyle(LinearGradient(colors: [.lunaBlush, .lunaBerry, .lunaLilac], startPoint: .topLeading, endPoint: .bottomTrailing)) }
            VStack(spacing: 12) { Text("Benvenuta in Lunaria").font(.system(size: 35, weight: .bold, design: .rounded)).multilineTextAlignment(.center); Text("Un modo delicato, semplice e privato per conoscere meglio il tuo ciclo.").font(.title3).foregroundStyle(.secondary).multilineTextAlignment(.center) }
            Spacer()
        }.padding(.horizontal, 28)
    }

    private var profile: some View {
        VStack(spacing: 24) { Spacer(); Image(systemName: "person.crop.circle.fill.badge.plus").font(.system(size: 88)).foregroundStyle(.lunaBerry); VStack(spacing: 9) { Text("Come ti chiami?").font(.system(size: 34, weight: .bold, design: .rounded)); Text("Useremo il tuo nome per rendere Lunaria più personale.").foregroundStyle(.secondary).multilineTextAlignment(.center) }; TextField("Il tuo nome", text: $name).font(.title3.bold()).textInputAutocapitalization(.words).padding(18).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20)).overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.7))); Spacer() }.padding(.horizontal, 28)
    }

    private var cycle: some View {
        ScrollView { VStack(spacing: 24) { Spacer(minLength: 45); Image(systemName: "calendar.badge.clock").font(.system(size: 78)).foregroundStyle(.lunaBerry); VStack(spacing: 8) { Text("Impostiamo il tuo ciclo").font(.system(size: 32, weight: .bold, design: .rounded)); Text("Potrai modificare tutto in qualsiasi momento.").foregroundStyle(.secondary) }; FrostCard(radius: 28, padding: 20) { VStack(spacing: 18) { DatePicker("Ultimo inizio", selection: $lastStart, in: ...Date(), displayedComponents: .date); Divider(); Stepper("Durata ciclo: \(cycleLength) giorni", value: $cycleLength, in: 20...45); Divider(); Stepper("Mestruazioni: \(periodLength) giorni", value: $periodLength, in: 2...10) } } }.padding(.horizontal, 24) }
    }

    private func next() {
        if page < 2 { withAnimation { page += 1 } } else { store.userName = name.trimmingCharacters(in: .whitespacesAndNewlines); store.settings = CycleSettings(lastPeriodStart: lastStart, averageCycleLength: cycleLength, averagePeriodLength: periodLength); store.hasCompletedOnboarding = true; store.syncToICloud() }
    }
}
