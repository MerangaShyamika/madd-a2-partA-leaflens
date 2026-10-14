import SwiftUI
import SwiftData

@main
struct LeafLensApp: App {
    /// Launch arguments used by UI tests:
    /// -uiTesting        → in-memory database, so every test starts empty
    /// -resetOnboarding  → shows onboarding again
    /// -skipOnboarding   → starts straight on the tabs (read in RootTabView)
    init() {
        if ProcessInfo.processInfo.arguments.contains("-resetOnboarding") {
            UserDefaults.standard.removeObject(forKey: "hasSeenOnboarding")
        }
    }

    /// SwiftData container holding plants and their scan records.
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Plant.self, ScanRecord.self])
        let inMemory = ProcessInfo.processInfo.arguments.contains("-uiTesting")
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
