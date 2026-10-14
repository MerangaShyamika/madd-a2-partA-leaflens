import SwiftUI

/// The app's root: a tab bar with three tabs, each owning its own NavigationStack.
/// Shows onboarding on first launch.
struct RootTabView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var selectedTab: AppTab = .scan

    /// UI tests pass -skipOnboarding so they start straight on the tabs.
    private var showOnboarding: Binding<Bool> {
        Binding(
            get: {
                !hasSeenOnboarding && !ProcessInfo.processInfo.arguments.contains("-skipOnboarding")
            },
            set: { isShowing in
                if !isShowing { hasSeenOnboarding = true }
            }
        )
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Scan", systemImage: "camera.viewfinder", value: AppTab.scan) {
                ScanHomeView()
            }
            Tab("My Garden", systemImage: "leaf", value: AppTab.garden) {
                GardenListView()
            }
            Tab("Nearby", systemImage: "map", value: AppTab.nearby) {
                NearbyMapView()
            }
        }
        .tint(.green)
        .environment(\.selectTab, { tab in selectedTab = tab })
        .fullScreenCover(isPresented: showOnboarding) {
            OnboardingView()
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [Plant.self, ScanRecord.self], inMemory: true)
}
