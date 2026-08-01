import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: CycleStore
    @State private var showingLog = false
    private var progress: Double { min(1, Double(store.currentCycleDay) / Double(max(store.settings.averageCycleLength, 1))) }
    private var phase: String {
        if store.currentCycleDay <= store.settings.averagePeriodLength { return "Mestruazioni" }
        if Date() >= store.fertileStart && Date() <= store.fertileEnd { return "Finestra fertile" }
        return "Fase luteale"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AuraBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        header
                        cycleHero
                        SectionHeader(title: "In breve", subtitle: "Le informazioni più importanti di oggi")
                        HStack(spacing: 12) {
                            miniCard(icon: "calendar", title: "Prossimo ciclo", value: store.italianDate(store.nextPeriodStart, style: "d MMM"), tint: .lunaBerry)
                            miniCard(icon: "leaf.fill", title: "Fertilità", value: "\(store.italianDate(store.fertileStart, style: "d MMM"))–\(store.italianDate(store.fertileEnd, style: "d MMM"))", tint: .green)
                        }
                        journalCard
                        Text("Le previsioni sono indicative e non sostituiscono un parere medico o un metodo contraccettivo.")
                            .font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal)
                    }.padding(.horizontal, 18).padding(.top, 10).padding(.bottom, 110)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingLog) { DayLogView(date: Date()).presentationDetents([.large]).presentationCornerRadius(34) }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(store.userName.isEmpty ? "CIAO" : "CIAO, \(store.userName.uppercased())").font(.caption.weight(.bold)).tracking(1.5).foregroundStyle(.lunaBerry)
                Text("Il tuo ritmo, oggi").font(.system(size: 31, weight: .bold, design: .rounded))
            }
            Spacer()
            Button { showingLog = true } label: {
                Image(systemName: "plus").font(.title3.bold()).foregroundStyle(.white).frame(width: 50, height: 50)
                    .background(LinearGradient(colors: [.lunaBlush, .lunaBerry], startPoint: .topLeading, endPoint: .bottomTrailing), in: Circle())
                    .shadow(color: Color.lunaBerry.opacity(0.25), radius: 12, y: 7)
            }
        }
    }

    private var cycleHero: some View {
        FrostCard(radius: 34, padding: 22) {
            VStack(spacing: 21) {
                HStack { LunaBadge(title: phase, icon: "sparkles"); Spacer(); Text("Giorno \(store.currentCycleDay) di \(store.settings.averageCycleLength)").font(.caption.weight(.semibold)).foregroundStyle(.secondary) }
                ZStack {
                    Circle().stroke(Color.primary.opacity(0.06), lineWidth: 22)
                    Circle().trim(from: 0, to: progress)
                        .stroke(AngularGradient(colors: [.lunaBlush, .lunaBerry, .lunaLilac, .lunaBlush], center: .center), style: StrokeStyle(lineWidth: 22, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Circle().fill(.thinMaterial).padding(30)
                    VStack(spacing: 4) {
                        Text("\(store.daysUntilNextPeriod)").font(.system(size: 62, weight: .bold, design: .rounded))
                        Text(store.daysUntilNextPeriod == 1 ? "giorno" : "giorni").font(.headline)
                        Text("al prossimo ciclo").font(.caption).foregroundStyle(.secondary)
                    }
                }.frame(width: 245, height: 245)
                Button { showingLog = true } label: { Label("Registra come ti senti", systemImage: "plus.circle.fill") }.buttonStyle(PrimaryLunaButtonStyle())
            }
        }
    }

    private func miniCard(icon: String, title: String, value: String, tint: Color) -> some View {
        FrostCard(radius: 24, padding: 16) {
            VStack(alignment: .leading, spacing: 11) {
                Image(systemName: icon).foregroundStyle(tint).frame(width: 38, height: 38).background(tint.opacity(0.12), in: Circle())
                Text(value).font(.headline).minimumScaleFactor(0.75).lineLimit(1)
                Text(title).font(.caption).foregroundStyle(.secondary)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var journalCard: some View {
        let log = store.log(for: Date())
        return FrostCard(radius: 28, padding: 20) {
            VStack(alignment: .leading, spacing: 16) {
                HStack { VStack(alignment: .leading, spacing: 3) { Text("Diario di oggi").font(.title3.bold()); Text(store.italianDate(Date(), style: "EEEE d MMMM")).font(.subheadline).foregroundStyle(.secondary) }; Spacer(); Button("Modifica") { showingLog = true }.font(.subheadline.bold()).foregroundStyle(.lunaBerry) }
                Divider().opacity(0.5)
                HStack(spacing: 10) {
                    LunaBadge(title: log.flow.rawValue, icon: log.flow.icon)
                    LunaBadge(title: log.symptoms.isEmpty ? "Nessun sintomo" : "\(log.symptoms.count) sintomi", icon: "heart.text.square", tint: .lunaLilac)
                }
            }
        }
    }
}
