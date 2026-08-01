import SwiftUI

struct DayLogView: View {
    @EnvironmentObject private var store: CycleStore
    @Environment(\.dismiss) private var dismiss
    let date: Date
    @State private var flow: FlowIntensity = .none
    @State private var symptoms: Set<Symptom> = []
    @State private var note = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AuraBackground()
                ScrollView {
                    VStack(spacing: 22) {
                        SectionHeader(title: "Come ti senti?", subtitle: store.italianDate(date, style: "EEEE d MMMM"))
                        FrostCard(radius: 28, padding: 20) { VStack(alignment: .leading, spacing: 16) { Text("Flusso").font(.title3.bold()); HStack(spacing: 8) { ForEach(FlowIntensity.allCases) { item in Button { flow = item } label: { VStack(spacing: 7) { Image(systemName: item.icon).font(.title3); Text(item.rawValue).font(.caption.bold()) }.foregroundStyle(flow == item ? .white : .primary).frame(maxWidth: .infinity).padding(.vertical, 12).background(flow == item ? Color.lunaBerry : Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 15)) } } } } }
                        FrostCard(radius: 28, padding: 20) { VStack(alignment: .leading, spacing: 16) { Text("Sintomi").font(.title3.bold()); LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) { ForEach(Symptom.allCases) { symptom in Button { if symptoms.contains(symptom) { symptoms.remove(symptom) } else { symptoms.insert(symptom) } } label: { Label(symptom.rawValue, systemImage: symptom.icon).font(.subheadline.weight(.semibold)).foregroundStyle(symptoms.contains(symptom) ? .white : .primary).frame(maxWidth: .infinity, alignment: .leading).padding(13).background(symptoms.contains(symptom) ? Color.lunaLilac : Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 15)) } } } } }
                        FrostCard(radius: 28, padding: 20) { VStack(alignment: .leading, spacing: 12) { Text("Note").font(.title3.bold()); TextEditor(text: $note).frame(minHeight: 105).scrollContentBackground(.hidden).padding(10).background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 16)) } }
                        Button { store.updateLog(DayLog(dateKey: store.dateKey(for: date), flow: flow, symptoms: Array(symptoms), note: note)); dismiss() } label: { Text("Salva la giornata") }.buttonStyle(PrimaryLunaButtonStyle())
                    }.padding(18).padding(.bottom, 25)
                }
            }.toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Chiudi") { dismiss() } } }
            .onAppear { let log = store.log(for: date); flow = log.flow; symptoms = Set(log.symptoms); note = log.note }
        }
    }
}
