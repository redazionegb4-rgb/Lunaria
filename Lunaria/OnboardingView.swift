import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: CycleStore
    @State private var page = 0
    @State private var lastPeriod = Date()
    @State private var cycleLength = 28
    @State private var periodLength = 5

    var body: some View {
        ZStack {
            LiquidBackground()
            VStack(spacing: 18) {
                HStack { Text("Lunaria").font(.system(size: 30, weight: .bold, design: .rounded)); Spacer(); Text("\(page + 1) di 3").font(.subheadline.weight(.semibold)).foregroundStyle(.secondary) }
                TabView(selection: $page) { welcome.tag(0); setup.tag(1); privacy.tag(2) }.tabViewStyle(.page(indexDisplayMode: .never))
                HStack(spacing: 8) { ForEach(0..<3) { index in Capsule().fill(index == page ? Color.lunariaRose : Color.primary.opacity(0.12)).frame(width: index == page ? 28 : 8, height: 8) } }.animation(.spring, value: page)
                Button(page == 2 ? "Entra in Lunaria" : "Continua") {
                    if page < 2 { withAnimation { page += 1 } } else { store.settings = CycleSettings(lastPeriodStart: lastPeriod, averageCycleLength: cycleLength, averagePeriodLength: periodLength); store.hasCompletedOnboarding = true }
                }.buttonStyle(GradientButtonStyle())
            }.padding(22)
        }
    }

    private var welcome: some View {
        VStack(spacing: 26) {
            Spacer()
            ZStack {
                Circle().fill(LinearGradient(colors: [.lunariaCoral, .lunariaRose, .lunariaPlum], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 160, height: 160).shadow(color: Color.lunariaRose.opacity(0.28), radius: 30, y: 18)
                Image(systemName: "drop.fill").font(.system(size: 72, weight: .semibold)).foregroundStyle(.white)
                Image(systemName: "sparkle").font(.system(size: 28, weight: .bold)).foregroundStyle(.white).offset(x: 48, y: -46)
            }
            Text("Il tuo ciclo, più semplice da capire").font(.system(size: 34, weight: .bold, design: .rounded)).multilineTextAlignment(.center)
            Text("Segui il ciclo, registra sintomi e benessere e scopri i tuoi ritmi in uno spazio privato e intuitivo.").foregroundStyle(.secondary).multilineTextAlignment(.center).font(.title3)
            Spacer()
        }.padding(.horizontal, 6)
    }

    private var setup: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 24) {
                Image(systemName: "calendar.badge.clock").font(.largeTitle).foregroundStyle(Color.lunariaRose)
                Text("Conosciamo il tuo ciclo").font(.system(size: 30, weight: .bold, design: .rounded))
                DatePicker("Inizio ultimo ciclo", selection: $lastPeriod, in: ...Date(), displayedComponents: .date)
                Divider()
                Stepper("Ciclo medio: \(cycleLength) giorni", value: $cycleLength, in: 20...45)
                Stepper("Mestruazioni: \(periodLength) giorni", value: $periodLength, in: 2...10)
                Spacer()
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var privacy: some View {
        VStack(spacing: 26) {
            Spacer()
            Image(systemName: "lock.shield.fill").font(.system(size: 78)).foregroundStyle(LinearGradient(colors: [.lunariaRose, .lunariaPlum], startPoint: .top, endPoint: .bottom))
            Text("La tua privacy viene prima").font(.system(size: 34, weight: .bold, design: .rounded)).multilineTextAlignment(.center)
            Text("I dati di questa versione restano sul tuo dispositivo. Puoi modificarli o cancellarli dalle impostazioni in qualsiasi momento.").font(.title3).foregroundStyle(.secondary).multilineTextAlignment(.center)
            GlassCard { Label("Nessun account richiesto", systemImage: "checkmark.seal.fill").font(.headline).frame(maxWidth: .infinity, alignment: .leading) }
            Spacer()
        }.padding(.horizontal, 4)
    }
}
