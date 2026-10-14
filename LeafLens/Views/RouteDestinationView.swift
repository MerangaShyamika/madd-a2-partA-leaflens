import SwiftUI

/// Maps each Route to the screen it shows.
/// Shared by every tab's NavigationStack so the mapping lives in one place.
struct RouteDestinationView: View {
    let route: Route

    var body: some View {
        switch route {
        case .plantDetail(let plant):
            PlantDetailView(plant: plant)

        case .settings:
            ContentUnavailableView(
                "Settings",
                systemImage: "gearshape",
                description: Text("Theme, language and data options will appear here.")
            )
            .navigationTitle("Settings")
        }
    }
}
