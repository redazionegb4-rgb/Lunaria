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
                LiquidBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Flusso").font(.headline)
                                Picker("Flusso", selection: $flow) {
                                    ForEach(FlowIntensity.allCases) { Text($0.rawValue).tag($0) }
                                }
                                .pickerStyle(.segmented)
                            }
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Sintomi").font(.headline)
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    ForEach(Symptom.allCases) { symptom in
                                        Button {
                                            if symptoms.contains(symptom) { symptoms.remove(symptom) } else { symptoms.insert(symptom) }
                                        } label: {
                                            Label(symptom.rawValue, systemImage: symptom.icon)
                                                .font(.subheadline.weight(.semibold))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(12)
                                                .background(symptoms.contains(symptom) ? Color.lunariaRose.opacity(0.18) : Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 15))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Note").font(.headline)
                                TextEditor(text: $note)
                                    .frame(minHeight: 120)
                                    .scrollContentBackground(.hidden)
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(date.formatted(.dateTime.day().month(.wide)))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Annulla") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        let log = DayLog(dateKey: store.dateKey(for: date), flow: flow, symptoms: Array(symptoms), note: note)
                        store.updateLog(log)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                let log = store.log(for: date)
                flow = log.flow
                symptoms = Set(log.symptoms)
                note = log.note
            }
        }
    }
}
