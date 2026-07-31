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
            VStack(spacing: 20) {
                HStack {
                    Text("Lunaria")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    Spacer()
                    Text("\(page + 1)/3")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                TabView(selection: $page) {
                    welcome.tag(0)
                    setup.tag(1)
                    privacy.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                Button(page == 2 ? "Inizia" : "Continua") {
                    if page < 2 {
                        withAnimation { page += 1 }
                    } else {
                        store.settings = CycleSettings(lastPeriodStart: lastPeriod, averageCycleLength: cycleLength, averagePeriodLength: periodLength)
                        store.hasCompletedOnboarding = true
                    }
                }
                .buttonStyle(GradientButtonStyle())
            }
            .padding(24)
        }
    }

    private var welcome: some View {
        GlassCard {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.22))
                        .frame(width: 140, height: 140)
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 64))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.white, Color.lunariaPink)
                }
                Text("Il tuo ciclo, con più chiarezza")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                Text("Registra il ciclo, i sintomi e il tuo benessere in uno spazio semplice, elegante e privato.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var setup: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 22) {
                Text("Configura il tuo ciclo")
                    .font(.title.bold())
                DatePicker("Ultimo ciclo iniziato", selection: $lastPeriod, in: ...Date(), displayedComponents: .date)
                Stepper("Durata media ciclo: \(cycleLength) giorni", value: $cycleLength, in: 20...45)
                Stepper("Durata mestruazioni: \(periodLength) giorni", value: $periodLength, in: 2...10)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var privacy: some View {
        GlassCard {
            VStack(spacing: 24) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(Color.lunariaViolet)
                Text("I tuoi dati restano sul dispositivo")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                Text("Questa prima versione salva tutto localmente. Lunaria non sostituisce il parere di un medico e le previsioni sono indicative.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
