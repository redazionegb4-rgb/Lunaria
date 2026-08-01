import Foundation
import SwiftUI

enum AppAppearance: String, CaseIterable, Codable, Identifiable {
    case system = "Automatico"
    case light = "Chiaro"
    case dark = "Scuro"
    var id: String { rawValue }
    var colorScheme: ColorScheme? {
        switch self { case .system: nil; case .light: .light; case .dark: .dark }
    }
}

enum FlowIntensity: String, CaseIterable, Codable, Identifiable {
    case none = "Nessuno", light = "Leggero", medium = "Medio", heavy = "Abbondante"
    var id: String { rawValue }
    var icon: String { self == .none ? "drop" : "drop.fill" }
}

enum Symptom: String, CaseIterable, Codable, Identifiable {
    case cramps = "Crampi", headache = "Mal di testa", bloating = "Gonfiore", fatigue = "Stanchezza"
    case mood = "Umore", skin = "Pelle", sleep = "Sonno", appetite = "Appetito"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .cramps: "waveform.path.ecg"; case .headache: "brain.head.profile"; case .bloating: "circle.dotted"
        case .fatigue: "battery.25percent"; case .mood: "face.smiling"; case .skin: "sparkles"
        case .sleep: "moon.stars.fill"; case .appetite: "fork.knife"
        }
    }
}

struct DayLog: Codable, Identifiable, Equatable {
    var id: String { dateKey }
    let dateKey: String
    var flow: FlowIntensity
    var symptoms: [Symptom]
    var note: String
}

struct CycleSettings: Codable {
    var lastPeriodStart: Date
    var averageCycleLength: Int
    var averagePeriodLength: Int
}

struct LunariaCloudBackup: Codable {
    let version: Int
    let updatedAt: Date
    let hasCompletedOnboarding: Bool
    let userName: String
    let settings: CycleSettings
    let logs: [String: DayLog]
    let appearance: AppAppearance
    let notificationsEnabled: Bool
}
