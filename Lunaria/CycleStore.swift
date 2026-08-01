import Foundation

@MainActor
final class CycleStore: NSObject, ObservableObject {
    @Published var hasCompletedOnboarding: Bool { didSet { persist() } }
    @Published var userName: String { didSet { persist() } }
    @Published var settings: CycleSettings { didSet { persist() } }
    @Published var logs: [String: DayLog] { didSet { persist() } }
    @Published var appearance: AppAppearance { didSet { persist() } }
    @Published var notificationsEnabled: Bool { didSet { persist() } }
    @Published private(set) var cloudStatus = "In attesa di iCloud"
    @Published private(set) var lastCloudSync: Date?

    private let defaults = UserDefaults.standard
    private let cloud = NSUbiquitousKeyValueStore.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let cloudKey = "lunaria.cloud.backup.v1"
    private var isRestoring = false

    override init() {
        hasCompletedOnboarding = defaults.bool(forKey: "hasCompletedOnboarding")
        userName = defaults.string(forKey: "userName") ?? ""
        notificationsEnabled = defaults.object(forKey: "notificationsEnabled") as? Bool ?? true
        appearance = AppAppearance(rawValue: defaults.string(forKey: "appearance") ?? "") ?? .system
        let startupDecoder = JSONDecoder()
        if let settingsData = defaults.data(forKey: "cycleSettings"),
           let savedSettings = try? startupDecoder.decode(CycleSettings.self, from: settingsData) {
            settings = savedSettings
        } else {
            settings = CycleSettings(
                lastPeriodStart: Calendar.current.date(byAdding: .day, value: -9, to: Date()) ?? Date(),
                averageCycleLength: 28,
                averagePeriodLength: 5
            )
        }

        if let logsData = defaults.data(forKey: "dayLogs"),
           let savedLogs = try? startupDecoder.decode([String: DayLog].self, from: logsData) {
            logs = savedLogs
        } else {
            logs = [:]
        }
        lastCloudSync = defaults.object(forKey: "lastCloudSync") as? Date

        super.init()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iCloudStoreDidChange(_:)),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: cloud
        )
        cloud.synchronize()
        restoreFromICloud(silent: true)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    @objc private func iCloudStoreDidChange(_ notification: Notification) {
        restoreFromICloud(silent: true)
    }

    private func persist() {
        guard !isRestoring else { return }
        defaults.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        defaults.set(userName, forKey: "userName")
        defaults.set(notificationsEnabled, forKey: "notificationsEnabled")
        defaults.set(appearance.rawValue, forKey: "appearance")
        defaults.set(try? encoder.encode(settings), forKey: "cycleSettings")
        defaults.set(try? encoder.encode(logs), forKey: "dayLogs")
        syncToICloud()
    }

    func syncToICloud() {
        let backup = LunariaCloudBackup(version: 1, updatedAt: Date(), hasCompletedOnboarding: hasCompletedOnboarding, userName: userName, settings: settings, logs: logs, appearance: appearance, notificationsEnabled: notificationsEnabled)
        guard let data = try? encoder.encode(backup) else { cloudStatus = "Errore durante il backup"; return }
        cloud.set(data, forKey: cloudKey)
        let ok = cloud.synchronize()
        lastCloudSync = backup.updatedAt
        defaults.set(backup.updatedAt, forKey: "lastCloudSync")
        cloudStatus = ok ? "Backup iCloud aggiornato" : "Backup salvato, sincronizzazione in corso"
    }

    func restoreFromICloud(silent: Bool = false) {
        guard let data = cloud.data(forKey: cloudKey), let backup = try? decoder.decode(LunariaCloudBackup.self, from: data) else {
            if !silent { cloudStatus = "Nessun backup iCloud trovato" }
            return
        }
        if silent, let local = lastCloudSync, backup.updatedAt <= local { return }
        isRestoring = true
        hasCompletedOnboarding = backup.hasCompletedOnboarding
        userName = backup.userName
        settings = backup.settings
        logs = backup.logs
        appearance = backup.appearance
        notificationsEnabled = backup.notificationsEnabled
        isRestoring = false
        lastCloudSync = backup.updatedAt
        defaults.set(backup.updatedAt, forKey: "lastCloudSync")
        cloudStatus = "Dati ripristinati da iCloud"
        persistLocalOnly()
    }

    private func persistLocalOnly() {
        defaults.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        defaults.set(userName, forKey: "userName")
        defaults.set(notificationsEnabled, forKey: "notificationsEnabled")
        defaults.set(appearance.rawValue, forKey: "appearance")
        defaults.set(try? encoder.encode(settings), forKey: "cycleSettings")
        defaults.set(try? encoder.encode(logs), forKey: "dayLogs")
    }

    func dateKey(for date: Date) -> String {
        let f = DateFormatter(); f.calendar = .current; f.locale = Locale(identifier: "it_IT"); f.dateFormat = "yyyy-MM-dd"; return f.string(from: date)
    }
    func log(for date: Date) -> DayLog { logs[dateKey(for: date)] ?? DayLog(dateKey: dateKey(for: date), flow: .none, symptoms: [], note: "") }
    func updateLog(_ log: DayLog) { logs[log.dateKey] = log }
    func italianDate(_ date: Date, style: String = "d MMMM") -> String {
        let f = DateFormatter(); f.locale = Locale(identifier: "it_IT"); f.dateFormat = style; return f.string(from: date).capitalized
    }
    var nextPeriodStart: Date { Calendar.current.date(byAdding: .day, value: settings.averageCycleLength, to: settings.lastPeriodStart) ?? Date() }
    var fertileStart: Date { Calendar.current.date(byAdding: .day, value: -19, to: nextPeriodStart) ?? Date() }
    var fertileEnd: Date { Calendar.current.date(byAdding: .day, value: -13, to: nextPeriodStart) ?? Date() }
    var daysUntilNextPeriod: Int { max(0, Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: nextPeriodStart)).day ?? 0) }
    var currentCycleDay: Int { max(1, (Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: settings.lastPeriodStart), to: Calendar.current.startOfDay(for: Date())).day ?? 0) + 1) }
    func resetAll() { isRestoring = true; logs = [:]; userName = ""; settings = CycleSettings(lastPeriodStart: Date(), averageCycleLength: 28, averagePeriodLength: 5); hasCompletedOnboarding = false; isRestoring = false; persist() }
}
