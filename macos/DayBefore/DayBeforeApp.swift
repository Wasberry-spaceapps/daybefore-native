import SwiftUI

@main
struct DayBeforeApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
        .windowStyle(.hiddenTitleBar)
    }
}

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var dataKey: Data?

    init() {
        isLoggedIn = SettingsService.shared.token != nil
    }
}
