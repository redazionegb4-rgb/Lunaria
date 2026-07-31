import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: CycleStore

    var body: some View {
        Group {
            if store.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut, value: store.hasCompletedOnboarding)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Oggi", systemImage: "sparkles") }
            CalendarView()
                .tabItem { Label("Calendario", systemImage: "calendar") }
            InsightsView()
                .tabItem { Label("Analisi", systemImage: "chart.xyaxis.line") }
            SettingsView()
                .tabItem { Label("Impostazioni", systemImage: "gearshape.fill") }
        }
        .tint(Color.lunariaPink)
    }
}
