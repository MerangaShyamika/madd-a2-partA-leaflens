import MapKit
import SwiftUI

/// Nearby tab: a map of agro shops, fertilizer sellers and nurseries near the user.
struct NearbyMapView: View {
    @State private var location = LocationManager()
    @State private var viewModel = NearbyViewModel()

    @State private var position: MapCameraPosition = .userLocation(fallback: .region(.colombo))
    @State private var visibleRegion: MKCoordinateRegion = .colombo
    @State private var selectedPlaceID: Place.ID?
    @State private var hasCenteredOnUser = false

    @Environment(\.openURL) private var openURL

    /// Converts the map's selected pin id into a Place for the sheet.
    private var selectedPlace: Binding<Place?> {
        Binding(
            get: { viewModel.places.first { $0.id == selectedPlaceID } },
            set: { selectedPlaceID = $0?.id }
        )
    }

    var body: some View {
        NavigationStack {
            Map(position: $position, selection: $selectedPlaceID) {
                UserAnnotation()
                ForEach(viewModel.places) { place in
                    Marker(place.name, systemImage: viewModel.category.icon, coordinate: place.coordinate)
                        .tint(.green)
                        .tag(place.id)
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                visibleRegion = context.region
            }
            .safeAreaInset(edge: .top) { categoryPicker }
            .safeAreaInset(edge: .bottom) { statusBar }
            .navigationTitle("Nearby")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: selectedPlace) { place in
                PlaceDetailSheet(place: place, userLocation: location.lastLocation)
            }
            .task {
                location.requestPermission()
                await viewModel.search(in: visibleRegion)
            }
            .onChange(of: viewModel.category) {
                Task { await viewModel.search(in: visibleRegion) }
            }
            .onChange(of: location.lastLocation) { _, newLocation in
                // The first time we learn where the user is, search around them.
                guard let newLocation, !hasCenteredOnUser else { return }
                hasCenteredOnUser = true
                visibleRegion = MKCoordinateRegion(
                    center: newLocation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                )
                Task { await viewModel.search(in: visibleRegion) }
            }
        }
    }

    /// Segmented control to switch between place categories.
    private var categoryPicker: some View {
        Picker("Category", selection: $viewModel.category) {
            ForEach(NearbyViewModel.Category.allCases) { category in
                Text(category.rawValue).tag(category)
            }
        }
        .pickerStyle(.segmented)
        .padding(8)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal)
        .padding(.top, 8)
    }

    /// Result count, errors, a fallback to Apple Maps, and "Search this area".
    private var statusBar: some View {
        VStack(spacing: 10) {
            HStack {
                if viewModel.isSearching {
                    ProgressView()
                    Text("Searching…")
                } else if let error = viewModel.errorMessage {
                    Label(error, systemImage: "wifi.exclamationmark")
                        .foregroundStyle(.orange)
                } else if viewModel.hasSearched {
                    Text(viewModel.places.isEmpty
                         ? "No \(viewModel.category.rawValue.lowercased()) found here"
                         : "\(viewModel.places.count) places found")
                }
                Spacer()
                Button("Search this area") {
                    Task { await viewModel.search(in: visibleRegion) }
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(viewModel.isSearching)
            }
            .font(.subheadline)

            if viewModel.hasSearched && viewModel.places.isEmpty && !viewModel.isSearching {
                Button {
                    openAppleMapsSearch()
                } label: {
                    Label("Search in Apple Maps instead", systemImage: "map")
                }
                .font(.subheadline)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding()
    }

    /// Fallback when Apple Maps has few listings in an area.
    private func openAppleMapsSearch() {
        let center = visibleRegion.center
        var components = URLComponents(string: "https://maps.apple.com/")
        components?.queryItems = [
            URLQueryItem(name: "q", value: viewModel.category.query),
            URLQueryItem(name: "sll", value: "\(center.latitude),\(center.longitude)")
        ]
        if let url = components?.url { openURL(url) }
    }
}

#Preview {
    NearbyMapView()
}
