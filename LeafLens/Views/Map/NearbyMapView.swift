import SwiftUI

/// Nearby tab: will show agro shops and Krushi Seva centres on a map (Phase 5).
struct NearbyMapView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Nearby Help",
                systemImage: "map",
                description: Text("Agro shops and Krushi Seva centres near you will appear here.")
            )
            .navigationTitle("Nearby")
        }
    }
}

#Preview {
    NearbyMapView()
}
