import SwiftUI

/// The app's root: a tab bar with three tabs, each owning its own NavigationStack.
struct RootTabView: View {
    var body: some View {
        TabView {
            Tab("Scan", systemImage: "camera.viewfinder") {
                ScanHomeView()
            }
            Tab("My Garden", systemImage: "leaf") {
                GardenListView()
            }
            Tab("Nearby", systemImage: "map") {
                NearbyMapView()
            }
        }
        .tint(.green)
    }
}

#Preview {
    RootTabView()
}
