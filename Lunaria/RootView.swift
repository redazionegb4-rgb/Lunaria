import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: CycleStore
    var body: some View {
        Group { store.hasCompletedOnboarding ? AnyView(MainTabView()) : AnyView(OnboardingView()) }
            .preferredColorScheme(store.appearance.colorScheme)
            .environment(\.locale, Locale(identifier: "it_IT"))
            .animation(.easeInOut(duration: 0.35), value: store.hasCompletedOnboarding)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView().tabItem { Label("Oggi", systemImage: "sparkles") }
            CalendarView().tabItem { Label("Calendario", systemImage: "calendar") }
            InsightsView().tabItem { Label("Analisi", systemImage: "chart.xyaxis.line") }
            SettingsView().tabItem { Label("Profilo", systemImage: "person.crop.circle") }
        }
        .tint(Color.lunaBerry)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
    }
}
