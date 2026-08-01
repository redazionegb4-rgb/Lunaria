import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: CycleStore
    @State private var showReset = false
    @State private var showCloudAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                AuraBackground()
                ScrollView {
                    VStack(spacing: 20) {
                        profileHeader
                        settingsCard(title: "Il tuo ciclo", icon: "calendar.badge.clock") {
                            DatePicker("Ultimo inizio", selection: $store.settings.lastPeriodStart, in: ...Date(), displayedComponents: .date)
                            Divider()
                            Stepper("Durata ciclo: \(store.settings.averageCycleLength) giorni", value: $store.settings.averageCycleLength, in: 20...45)
                            Divider()
                            Stepper("Mestruazioni: \(store.settings.averagePeriodLength) giorni", value: $store.settings.averagePeriodLength, in: 2...10)
                        }
                        settingsCard(title: "iCloud", icon: "icloud.fill") {
                            HStack { VStack(alignment: .leading, spacing: 3) { Text("Backup automatico").font(.headline); Text(store.cloudStatus).font(.caption).foregroundStyle(.secondary) }; Spacer(); Image(systemName: "checkmark.icloud.fill").font(.title2).foregroundStyle(.green) }
                            if let date = store.lastCloudSync { Text("Ultimo aggiornamento: \(store.italianDate(date, style: "d MMMM, HH:mm"))").font(.caption).foregroundStyle(.secondary) }
                            Divider()
                            Button { store.syncToICloud(); showCloudAlert = true } label: { Label("Esegui backup adesso", systemImage: "arrow.triangle.2.circlepath.icloud") }
                            Divider()
                            Button { store.restoreFromICloud(); showCloudAlert = true } label: { Label("Ripristina da iCloud", systemImage: "icloud.and.arrow.down") }
                            Text("I dati vengono salvati nel tuo account iCloud e ripristinati automaticamente sugli altri iPhone con lo stesso Apple ID.").font(.caption).foregroundStyle(.secondary)
                        }
                        settingsCard(title: "Preferenze", icon: "slider.horizontal.3") {
                            Picker("Aspetto", selection: $store.appearance) { ForEach(AppAppearance.allCases) { Text($0.rawValue).tag($0) } }
                            Divider(); Toggle("Promemoria", isOn: $store.notificationsEnabled)
                        }
                        settingsCard(title: "Privacy", icon: "lock.shield.fill") {
                            Label("Nessun account richiesto", systemImage: "person.crop.circle.badge.checkmark")
                            Divider(); Label("Dati protetti da iCloud", systemImage: "icloud.fill")
                            Divider(); Label("Previsioni indicative", systemImage: "cross.case.fill")
                        }
                        Button("Azzera tutti i dati", role: .destructive) { showReset = true }.font(.headline).padding(.top, 4)
                    }.padding(18).padding(.bottom, 105)
                }
            }.toolbar(.hidden, for: .navigationBar)
            .alert("iCloud", isPresented: $showCloudAlert) { Button("OK") {} } message: { Text(store.cloudStatus) }
            .alert("Azzera Lunaria?", isPresented: $showReset) { Button("Annulla", role: .cancel) {}; Button("Azzera", role: .destructive) { store.resetAll() } } message: { Text("Tutti i dati locali verranno eliminati e il backup iCloud verrà aggiornato.") }
        }
    }

    private var profileHeader: some View {
        FrostCard(radius: 32, padding: 22) {
            HStack(spacing: 16) {
                ZStack { Circle().fill(LinearGradient(colors: [.lunaBlush, .lunaBerry, .lunaLilac], startPoint: .topLeading, endPoint: .bottomTrailing)); Image(systemName: "moon.stars.fill").font(.title).foregroundStyle(.white) }.frame(width: 64, height: 64)
                VStack(alignment: .leading, spacing: 5) { Text("Il tuo profilo").font(.caption.bold()).foregroundStyle(.lunaBerry); TextField("Nome", text: $store.userName).font(.title2.bold()).textInputAutocapitalization(.words) }
                Spacer()
            }
        }
    }

    private func settingsCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        FrostCard(radius: 28, padding: 20) { VStack(alignment: .leading, spacing: 14) { Label(title, systemImage: icon).font(.title3.bold()).foregroundStyle(.lunaInk); content() }.frame(maxWidth: .infinity, alignment: .leading) }
    }
}
