import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject private var store: CycleStore

    private var symptomCounts: [(String, Int)] {
        Symptom.allCases.map { symptom in
            (symptom.rawValue, store.logs.values.filter { $0.symptoms.contains(symptom) }.count)
        }.filter { $0.1 > 0 }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()
                ScrollView {
                    VStack(spacing: 18) {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Riepilogo ciclo").font(.title3.bold())
                                HStack {
                                    stat("Durata media", "\(store.settings.averageCycleLength) gg")
                                    stat("Mestruazioni", "\(store.settings.averagePeriodLength) gg")
                                    stat("Giorni registrati", "\(store.logs.count)")
                                }
                            }
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Sintomi registrati").font(.title3.bold())
                                if symptomCounts.isEmpty {
                                    ContentUnavailableView("Nessun dato", systemImage: "chart.bar", description: Text("Registra alcuni sintomi per vedere le tendenze."))
                                        .frame(height: 230)
                                } else {
                                    Chart(symptomCounts, id: \.0) { item in
                                        BarMark(x: .value("Sintomo", item.0), y: .value("Volte", item.1))
                                            .foregroundStyle(LinearGradient(colors: [Color.lunariaPink, Color.lunariaViolet], startPoint: .bottom, endPoint: .top))
                                    }
                                    .frame(height: 250)
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Analisi")
        }
    }

    private func stat(_ title: String, _ value: String) -> some View {
        VStack(spacing: 6) {
            Text(value).font(.title3.bold())
            Text(title).font(.caption2).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}
