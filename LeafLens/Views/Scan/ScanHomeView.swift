import SwiftUI

/// Scan tab: the entry point for checking a leaf photo.
struct ScanHomeView: View {
    /// Icon size that grows with Dynamic Type (accessibility).
    @ScaledMetric private var iconSize: CGFloat = 72

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: iconSize))
                    .foregroundStyle(.green)
                    .accessibilityHidden(true)

                Text("Check a leaf")
                    .font(.title2.bold())

                Text("Pick a clear photo of one leaf to find out if your plant is healthy.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                NavigationLink(value: Route.scanResult) {
                    Label("Scan a leaf", systemImage: "camera.viewfinder")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.green)
                .padding(.top, 8)
            }
            .padding(24)
            .navigationTitle("Scan")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: Route.settings) {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .navigationDestination(for: Route.self) { route in
                RouteDestinationView(route: route)
            }
        }
    }
}

#Preview {
    ScanHomeView()
}
