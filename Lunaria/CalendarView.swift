import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var store: CycleStore
    @State private var selectedDate = Date()
    @State private var showingLog = false

    var body: some View {
        NavigationStack {
            ZStack {
                AuraBackground()
                ScrollView {
                    VStack(spacing: 20) {
                        SectionHeader(title: "Calendario", subtitle: "Segui il tuo ciclo giorno per giorno")
                        FrostCard(radius: 30, padding: 16) {
                            DatePicker("Seleziona una data", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.graphical).tint(.lunaBerry).labelsHidden()
                        }
                        daySummary
                    }.padding(18).padding(.bottom, 100)
                }
            }.toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingLog) { DayLogView(date: selectedDate).presentationDetents([.large]).presentationCornerRadius(34) }
        }
    }

    private var daySummary: some View {
        let log = store.log(for: selectedDate)
        return FrostCard(radius: 28, padding: 20) {
            VStack(alignment: .leading, spacing: 15) {
                HStack { VStack(alignment: .leading) { Text(store.italianDate(selectedDate, style: "EEEE")).font(.caption.bold()).foregroundStyle(.lunaBerry); Text(store.italianDate(selectedDate, style: "d MMMM yyyy")).font(.title3.bold()) }; Spacer(); Image(systemName: "calendar.circle.fill").font(.largeTitle).foregroundStyle(.lunaLilac) }
                HStack { LunaBadge(title: log.flow.rawValue, icon: log.flow.icon); LunaBadge(title: "\(log.symptoms.count) sintomi", icon: "heart.text.square", tint: .lunaLilac) }
                Button { showingLog = true } label: { Label("Apri la giornata", systemImage: "square.and.pencil") }.buttonStyle(PrimaryLunaButtonStyle())
            }
        }
    }
}
