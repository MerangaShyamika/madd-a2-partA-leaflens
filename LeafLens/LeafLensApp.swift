import SwiftUI
import SwiftData

@main
struct LeafLensApp: App {
    /// SwiftData container holding plants and their scan records.
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Plant.self, ScanRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
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
