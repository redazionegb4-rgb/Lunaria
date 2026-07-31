import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: CycleStore
    var body: some View {
        Group { if store.hasCompletedOnboarding { MainTabView() } else { OnboardingView() } }
            .preferredColorScheme(store.appearance.colorScheme).animation(.easeInOut, value: store.hasCompletedOnboarding)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView().tabItem { Label("Oggi", systemImage: "house.fill") }
            CalendarView().tabItem { Label("Calendario", systemImage: "calendar") }
            InsightsView().tabItem { Label("Analisi", systemImage: "chart.bar.fill") }
            SettingsView().tabItem { Label("Profilo", systemImage: "person.crop.circle.fill") }
        }.tint(.lunariaRose)
    }
}
