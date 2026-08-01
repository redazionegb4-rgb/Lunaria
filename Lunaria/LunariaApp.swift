import SwiftUI

@main
struct LunariaApp: App {
    @StateObject private var store = CycleStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(store.appearance.colorScheme)
                .environment(\.locale, Locale(identifier: "it_IT"))
        }
    }
}
