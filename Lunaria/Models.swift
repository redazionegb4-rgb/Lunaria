import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let lunariaBackup = UTType(exportedAs: "com.dmb.lunaria.backup", conformingTo: .json)
}

enum AppAppearance: String, CaseIterable, Codable, Identifiable {
    case system = "Automatico"
    case light = "Chiaro"
    case dark = "Scuro"

    var id: String { rawValue }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

enum FlowIntensity: String, CaseIterable, Codable, Identifiable {
    case none = "Nessuno"
    case light = "Leggero"
    case medium = "Medio"
    case heavy = "Abbondante"

    var id: String { rawValue }
}

enum Symptom: String, CaseIterable, Codable, Identifiable {
    case cramps = "Crampi"
    case headache = "Mal di testa"
    case bloating = "Gonfiore"
    case fatigue = "Stanchezza"
    case mood = "Umore"
    case skin = "Pelle"
    case sleep = "Sonno"
    case appetite = "Appetito"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .cramps: "waveform.path.ecg"
        case .headache: "brain.head.profile"
        case .bloating: "circle.dotted"
        case .fatigue: "battery.25percent"
        case .mood: "face.smiling.inverse"
        case .skin: "sparkles"
        case .sleep: "moon.stars.fill"
        case .appetite: "fork.knife"
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

struct LunariaBackup: Codable {
    let version: Int
    let createdAt: Date
    let userName: String
    let settings: CycleSettings
    let logs: [String: DayLog]
    let appearance: AppAppearance
    let notificationsEnabled: Bool
}

struct LunariaBackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.lunariaBackup, .json] }

    var backup: LunariaBackup

    init(backup: LunariaBackup) {
        self.backup = backup
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        backup = try JSONDecoder().decode(LunariaBackup.self, from: data)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return FileWrapper(regularFileWithContents: try encoder.encode(backup))
    }
}
