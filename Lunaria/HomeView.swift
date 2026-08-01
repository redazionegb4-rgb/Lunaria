import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: CycleStore
    @State private var showingLog = false

    private var progress: Double { min(1, Double(store.currentCycleDay) / Double(max(store.settings.averageCycleLength, 1))) }
    private var phaseTitle: String {
        if store.currentCycleDay <= store.settings.averagePeriodLength { return "Mestruazioni" }
        if Date() >= store.fertileStart && Date() <= store.fertileEnd { return "Finestra fertile" }
        return "Fase del ciclo"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        header
                        hero
                        quickGrid
                        phaseCard
                        todayCard
                        Text("Le previsioni sono indicative e non sostituiscono un parere medico o un metodo contraccettivo.")
                            .font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 18)
                    }.padding(.horizontal, 18).padding(.bottom, 110)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingLog) { DayLogView(date: Date()).presentationDetents([.large]).presentationCornerRadius(32) }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(store.userName.isEmpty ? "Ciao" : "Ciao, \(store.userName)").font(.subheadline).foregroundStyle(.secondary)
                Text("Come ti senti oggi?").font(.system(size: 28, weight: .bold, design: .rounded))
            }
            Spacer()
            Button { showingLog = true } label: {
                Image(systemName: "plus").font(.headline).foregroundStyle(.white).frame(width: 48, height: 48)
                    .background(LinearGradient(colors: [.lunariaCoral, .lunariaPlum], startPoint: .topLeading, endPoint: .bottomTrailing), in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.55), lineWidth: 1))
            }
        }.padding(.top, 8)
    }

    private var hero: some View {
        GlassCard(padding: 20) {
            VStack(spacing: 20) {
                HStack { StatusPill(text: phaseTitle, icon: "sparkles"); Spacer(); Text("Giorno \(store.currentCycleDay)").font(.subheadline.weight(.semibold)).foregroundStyle(.secondary) }
                ZStack {
                    Circle().stroke(Color.primary.opacity(0.07), lineWidth: 18)
                    Circle().trim(from: 0, to: progress).stroke(AngularGradient(colors: [.lunariaCoral, .lunariaRose, .lunariaPlum, .lunariaCoral], center: .center), style: StrokeStyle(lineWidth: 18, lineCap: .round)).rotationEffect(.degrees(-90))
                    Circle().fill(.ultraThinMaterial).padding(25)
                    VStack(spacing: 2) {
                        Text("\(store.daysUntilNextPeriod)").font(.system(size: 58, weight: .bold, design: .rounded))
                        Text(store.daysUntilNextPeriod == 1 ? "giorno al prossimo ciclo" : "giorni al prossimo ciclo").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    }.padding(.horizontal, 28)
                }.frame(width: 235, height: 235)
                Button { showingLog = true } label: { Label("Registra la giornata", systemImage: "square.and.pencil") }.buttonStyle(GradientButtonStyle())
            }
        }
    }

    private var quickGrid: some View {
        HStack(spacing: 12) {
            metric(title: "Prossimo ciclo", value: store.italianDate(store.nextPeriodStart, abbreviated: true), icon: "calendar", tint: .lunariaRose)
            metric(title: "Durata media", value: "\(store.settings.averageCycleLength) giorni", icon: "arrow.triangle.2.circlepath", tint: .lunariaPlum)
        }
    }

    private func metric(title: String, value: String, icon: String, tint: Color) -> some View {
        GlassCard(padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon).font(.headline).foregroundStyle(tint).frame(width: 38, height: 38).background(tint.opacity(0.12), in: Circle())
                Text(value).font(.headline)
                Text(title).font(.caption).foregroundStyle(.secondary)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var phaseCard: some View {
        GlassCard {
            HStack(spacing: 14) {
                Image(systemName: "leaf.fill").font(.title3).foregroundStyle(.green).frame(width: 46, height: 46).background(.green.opacity(0.12), in: Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text("Finestra fertile stimata").font(.headline)
                    Text("\(store.italianDate(store.fertileStart, abbreviated: true)) – \(store.italianDate(store.fertileEnd, abbreviated: true))").foregroundStyle(.secondary)
                }
                Spacer(); Image(systemName: "chevron.right").foregroundStyle(.tertiary)
            }
        }
    }

    private var todayCard: some View {
        let log = store.log(for: Date())
        return GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack { Text("Il tuo diario di oggi").font(.headline); Spacer(); Button("Modifica") { showingLog = true }.font(.subheadline.weight(.semibold)).foregroundStyle(Color.lunariaRose) }
                HStack(spacing: 10) {
                    StatusPill(text: log.flow.rawValue, icon: "drop.fill")
                    StatusPill(text: log.symptoms.isEmpty ? "Nessun sintomo" : "\(log.symptoms.count) sintomi", icon: "heart.text.square")
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
