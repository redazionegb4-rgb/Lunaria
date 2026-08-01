import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject private var store: CycleStore
    private var symptomCounts: [(String, Int)] {
        Symptom.allCases.map { symptom in (symptom.rawValue, store.logs.values.filter { $0.symptoms.contains(symptom) }.count) }.filter { $0.1 > 0 }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AuraBackground()
                ScrollView {
                    VStack(spacing: 20) {
                        SectionHeader(title: "Analisi", subtitle: "Comprendi meglio il tuo andamento")
                        HStack(spacing: 12) {
                            stat(value: "\(store.settings.averageCycleLength)", label: "giorni medi", icon: "arrow.triangle.2.circlepath")
                            stat(value: "\(store.logs.count)", label: "giorni registrati", icon: "checkmark.circle")
                        }
                        FrostCard(radius: 30, padding: 20) {
                            VStack(alignment: .leading, spacing: 18) {
                                Text("Sintomi più registrati").font(.title3.bold())
                                if symptomCounts.isEmpty {
                                    ContentUnavailableView("Nessun dato", systemImage: "chart.bar", description: Text("Registra alcune giornate per visualizzare le tue tendenze."))
                                } else {
                                    Chart(symptomCounts, id: \.0) { item in
                                        BarMark(x: .value("Sintomo", item.0), y: .value("Volte", item.1)).foregroundStyle(LinearGradient(colors: [.lunaBlush, .lunaLilac], startPoint: .bottom, endPoint: .top)).cornerRadius(7)
                                    }.frame(height: 220).chartYAxis(.hidden)
                                }
                            }
                        }
                        FrostCard(radius: 28, padding: 20) {
                            HStack(spacing: 15) { Image(systemName: "wand.and.stars").font(.title).foregroundStyle(.lunaBerry); VStack(alignment: .leading, spacing: 4) { Text("Più dati, più precisione").font(.headline); Text("Continua a registrare flusso e sintomi per rendere le previsioni più utili.").font(.subheadline).foregroundStyle(.secondary) } }
                        }
                    }.padding(18).padding(.bottom, 100)
                }
            }.toolbar(.hidden, for: .navigationBar)
        }
    }

    private func stat(value: String, label: String, icon: String) -> some View {
        FrostCard(radius: 24, padding: 17) { VStack(alignment: .leading, spacing: 8) { Image(systemName: icon).foregroundStyle(.lunaBerry); Text(value).font(.system(size: 32, weight: .bold, design: .rounded)); Text(label).font(.caption).foregroundStyle(.secondary) }.frame(maxWidth: .infinity, alignment: .leading) }
    }
}
