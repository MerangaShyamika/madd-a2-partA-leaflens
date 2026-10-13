import SwiftUI

/// Maps each Route to the screen it shows.
/// Shared by every tab's NavigationStack so the mapping lives in one place.
struct RouteDestinationView: View {
    let route: Route

    var body: some View {
        switch route {
        case .plantDetail(let name):
            ContentUnavailableView(
                name,
                systemImage: "leaf",
                description: Text("Plant details and scan history will appear here.")
            )
            .navigationTitle(name)

        case .scanResult:
            ContentUnavailableView(
                "Scan Result",
                systemImage: "checkmark.seal",
                description: Text("The disease prediction will appear here.")
            )
            .navigationTitle("Result")

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

#Preview {
    NavigationStack {
        RouteDestinationView(route: .scanResult)
    }
}
