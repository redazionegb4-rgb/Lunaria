import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var showingLog = false

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()
                ScrollView {
                    VStack(spacing: 18) {
                        DatePicker("Data", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .padding(8)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))

                        Button("Registra o modifica questa giornata") { showingLog = true }
                            .buttonStyle(GradientButtonStyle())
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Calendario")
            .sheet(isPresented: $showingLog) {
                DayLogView(date: selectedDate)
                    .presentationDetents([.large])
                    .presentationCornerRadius(30)
            }
        }
    }
}
