import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: CycleStore
    @State private var showingLog = false

    private var dateFormatter: DateFormatter {
        let f = DateFormatter(); f.locale = Locale(identifier: "it_IT"); f.dateFormat = "EEEE d MMMM"; return f
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()
                ScrollView {
                    VStack(spacing: 18) {
                        header
                        cycleHero
                        HStack(spacing: 14) {
                            miniCard(title: "Giorno ciclo", value: "\(store.currentCycleDay)", icon: "circle.hexagongrid.fill")
                            miniCard(title: "Prossimo ciclo", value: "\(store.daysUntilNextPeriod) gg", icon: "calendar.badge.clock")
                        }
                        fertileCard
                        todayCard
                        disclaimer
                    }
                    .padding(20)
                    .padding(.bottom, 80)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingLog) {
                DayLogView(date: Date())
                    .presentationDetents([.large])
                    .presentationCornerRadius(30)
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Lunaria")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                Text(dateFormatter.string(from: Date()).capitalized)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "moon.stars.fill")
                .font(.title2)
                .foregroundStyle(.white)
                .padding(14)
                .background(.ultraThinMaterial, in: Circle())
        }
    }

    private var cycleHero: some View {
        GlassCard {
            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.22), lineWidth: 18)
                    Circle()
                        .trim(from: 0, to: min(1, Double(store.currentCycleDay) / Double(store.settings.averageCycleLength)))
                        .stroke(
                            LinearGradient(colors: [Color.lunariaPink, Color.lunariaViolet], startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 18, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 4) {
                        Text("\(store.daysUntilNextPeriod)")
                            .font(.system(size: 54, weight: .bold, design: .rounded))
                        Text("giorni al ciclo")
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 220, height: 220)

                Button("Registra oggi") { showingLog = true }
                    .buttonStyle(GradientButtonStyle())
            }
        }
    }

    private func miniCard(title: String, value: String, icon: String) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon).foregroundStyle(Color.lunariaViolet)
                Text(value).font(.title2.bold())
                Text(title).font(.caption).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var fertileCard: some View {
        GlassCard {
            HStack(spacing: 16) {
                Image(systemName: "leaf.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
                    .padding(14)
                    .background(.green.opacity(0.12), in: Circle())
                VStack(alignment: .leading, spacing: 5) {
                    Text("Finestra fertile stimata").font(.headline)
                    Text(store.fertileStart.formatted(.dateTime.day().month(.wide)) + " – " + store.fertileEnd.formatted(.dateTime.day().month(.wide)))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
    }

    private var todayCard: some View {
        GlassCard {
            let log = store.log(for: Date())
            VStack(alignment: .leading, spacing: 14) {
                Text("Oggi").font(.title3.bold())
                HStack {
                    Label(log.flow.rawValue, systemImage: "drop.fill")
                    Spacer()
                    Text(log.symptoms.isEmpty ? "Nessun sintomo" : "\(log.symptoms.count) sintomi")
                }
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var disclaimer: some View {
        Text("Le previsioni sono stime basate sui dati inseriti e non sono uno strumento contraccettivo o diagnostico.")
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
}
