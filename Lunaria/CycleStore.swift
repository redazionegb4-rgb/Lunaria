import Foundation

@MainActor
final class CycleStore: ObservableObject {
    @Published var hasCompletedOnboarding: Bool { didSet { save() } }
    @Published var userName: String { didSet { save() } }
    @Published var settings: CycleSettings { didSet { save() } }
    @Published var logs: [String: DayLog] { didSet { save() } }
    @Published var appearance: AppAppearance { didSet { save() } }
    @Published var notificationsEnabled: Bool { didSet { save() } }

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        hasCompletedOnboarding = defaults.bool(forKey: "hasCompletedOnboarding")
        userName = defaults.string(forKey: "userName") ?? ""
        notificationsEnabled = defaults.object(forKey: "notificationsEnabled") as? Bool ?? true
        appearance = AppAppearance(rawValue: defaults.string(forKey: "appearance") ?? "") ?? .system

        if let data = defaults.data(forKey: "cycleSettings"),
           let decoded = try? decoder.decode(CycleSettings.self, from: data) {
            settings = decoded
        } else {
            settings = CycleSettings(
                lastPeriodStart: Calendar.current.date(byAdding: .day, value: -9, to: Date()) ?? Date(),
                averageCycleLength: 28,
                averagePeriodLength: 5
            )
        }

        if let data = defaults.data(forKey: "dayLogs"),
           let decoded = try? decoder.decode([String: DayLog].self, from: data) {
            logs = decoded
        } else {
            logs = [:]
        }
    }

    func save() {
        defaults.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        defaults.set(userName, forKey: "userName")
        defaults.set(notificationsEnabled, forKey: "notificationsEnabled")
        defaults.set(appearance.rawValue, forKey: "appearance")
        defaults.set(try? encoder.encode(settings), forKey: "cycleSettings")
        defaults.set(try? encoder.encode(logs), forKey: "dayLogs")
    }

    func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func log(for date: Date) -> DayLog {
        logs[dateKey(for: date)] ?? DayLog(dateKey: dateKey(for: date), flow: .none, symptoms: [], note: "")
    }

    func updateLog(_ log: DayLog) {
        logs[log.dateKey] = log
    }

    func italianDate(_ date: Date, abbreviated: Bool = false) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = abbreviated ? "d MMM" : "d MMMM"
        return formatter.string(from: date).capitalized
    }

    var backup: LunariaBackup {
        LunariaBackup(
            version: 1,
            createdAt: Date(),
            userName: userName,
            settings: settings,
            logs: logs,
            appearance: appearance,
            notificationsEnabled: notificationsEnabled
        )
    }

    func restore(from backup: LunariaBackup) {
        userName = backup.userName
        settings = backup.settings
        logs = backup.logs
        appearance = backup.appearance
        notificationsEnabled = backup.notificationsEnabled
        hasCompletedOnboarding = true
        save()
    }

    var nextPeriodStart: Date {
        Calendar.current.date(byAdding: .day, value: settings.averageCycleLength, to: settings.lastPeriodStart) ?? Date()
    }

    var fertileStart: Date {
        Calendar.current.date(byAdding: .day, value: -19, to: nextPeriodStart) ?? Date()
    }

    var fertileEnd: Date {
        Calendar.current.date(byAdding: .day, value: -13, to: nextPeriodStart) ?? Date()
    }

    var daysUntilNextPeriod: Int {
        max(0, Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: nextPeriodStart)).day ?? 0)
    }

    var currentCycleDay: Int {
        max(1, (Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: settings.lastPeriodStart), to: Calendar.current.startOfDay(for: Date())).day ?? 0) + 1)
    }

    func resetAll() {
        logs = [:]
        userName = ""
        settings = CycleSettings(lastPeriodStart: Date(), averageCycleLength: 28, averagePeriodLength: 5)
        hasCompletedOnboarding = false
    }
}
