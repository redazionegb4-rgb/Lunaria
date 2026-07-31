import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: CycleStore
    @State private var showReset = false

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()
                Form {
                    Section("Ciclo") {
                        DatePicker("Ultimo inizio", selection: $store.settings.lastPeriodStart, in: ...Date(), displayedComponents: .date)
                        Stepper("Durata ciclo: \(store.settings.averageCycleLength) giorni", value: $store.settings.averageCycleLength, in: 20...45)
                        Stepper("Durata mestruazioni: \(store.settings.averagePeriodLength) giorni", value: $store.settings.averagePeriodLength, in: 2...10)
                    }

                    Section("Preferenze") {
                        Picker("Aspetto", selection: $store.appearance) {
                            ForEach(AppAppearance.allCases) { Text($0.rawValue).tag($0) }
                        }
                        Toggle("Promemoria", isOn: $store.notificationsEnabled)
                    }

                    Section("Privacy e salute") {
                        Label("Dati salvati localmente", systemImage: "iphone.gen3.lock")
                        Label("Previsioni solo indicative", systemImage: "cross.case.fill")
                    }

                    Section {
                        Button("Azzera tutti i dati", role: .destructive) { showReset = true }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Impostazioni")
            .alert("Azzera Lunaria?", isPresented: $showReset) {
                Button("Annulla", role: .cancel) {}
                Button("Azzera", role: .destructive) { store.resetAll() }
            } message: {
                Text("Tutti i dati registrati verranno eliminati dal dispositivo.")
            }
        }
    }
}
