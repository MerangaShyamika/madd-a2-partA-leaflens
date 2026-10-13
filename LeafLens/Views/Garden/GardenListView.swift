import SwiftUI

/// My Garden tab: lists the user's saved plants.
/// Uses sample names for now; SwiftData replaces them in Phase 2.
struct GardenListView: View {
    /// Temporary sample data until persistence is added.
    private let samplePlants = ["Tomato 1", "Chilli", "Long Beans"]

    var body: some View {
        NavigationStack {
            List(samplePlants, id: \.self) { name in
                NavigationLink(value: Route.plantDetail(name: name)) {
                    Label(name, systemImage: "leaf")
                }
            }
            .navigationTitle("My Garden")
            .navigationDestination(for: Route.self) { route in
                RouteDestinationView(route: route)
            }
        }
    }
}

#Preview {
    GardenListView()
}
