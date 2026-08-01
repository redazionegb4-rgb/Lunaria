import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: CycleStore
    @State private var showReset = false
    @State private var showExporter = false
    @State private var showImporter = false
    @State private var backupDocument: LunariaBackupDocument?
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showResultAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()
                Form {
                    Section("Profilo") {
                        TextField("Nome", text: $store.userName)
                            .textInputAutocapitalization(.words)
                    }

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

                    Section("Backup") {
                        Button {
                            backupDocument = LunariaBackupDocument(backup: store.backup)
                            showExporter = true
                        } label: {
                            Label("Crea backup", systemImage: "square.and.arrow.up")
                        }

                        Button {
                            showImporter = true
                        } label: {
                            Label("Ripristina backup", systemImage: "square.and.arrow.down")
                        }

                        Text("Il backup contiene profilo, impostazioni del ciclo e giornate registrate. Puoi salvarlo su iCloud Drive o nell’app File.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
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
            .environment(\.locale, Locale(identifier: "it_IT"))
            .fileExporter(
                isPresented: $showExporter,
                document: backupDocument,
                contentType: .lunariaBackup,
                defaultFilename: "Backup-Lunaria"
            ) { result in
                switch result {
                case .success:
                    showMessage(title: "Backup creato", message: "I dati di Lunaria sono stati esportati correttamente.")
                case .failure(let error):
                    showMessage(title: "Backup non creato", message: error.localizedDescription)
                }
            }
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [.lunariaBackup, .json],
                allowsMultipleSelection: false
            ) { result in
                do {
                    let urls = try result.get()
                    guard let url = urls.first else { return }
                    let access = url.startAccessingSecurityScopedResource()
                    defer { if access { url.stopAccessingSecurityScopedResource() } }
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let backup = try decoder.decode(LunariaBackup.self, from: data)
                    store.restore(from: backup)
                    showMessage(title: "Backup ripristinato", message: "Tutti i dati sono stati importati correttamente.")
                } catch {
                    showMessage(title: "Backup non valido", message: "Il file selezionato non può essere ripristinato.")
                }
            }
            .alert("Azzera Lunaria?", isPresented: $showReset) {
                Button("Annulla", role: .cancel) {}
                Button("Azzera", role: .destructive) { store.resetAll() }
            } message: {
                Text("Tutti i dati registrati verranno eliminati dal dispositivo.")
            }
            .alert(alertTitle, isPresented: $showResultAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func showMessage(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showResultAlert = true
    }
}
