import MapKit
import SwiftUI

/// Bottom sheet with a place's details, distance, directions and call button.
/// Offers Google Maps as well, because Apple Maps routing is limited in Sri Lanka.
struct PlaceDetailSheet: View {
    let place: Place
    let userLocation: CLLocation?

    @Environment(\.openURL) private var openURL

    /// Straight-line distance from the user, e.g. "2.4 km away".
    private var distanceText: String? {
        guard let userLocation else { return nil }
        let target = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        let kilometres = userLocation.distance(from: target) / 1000
        return String(format: "%.1f km away", kilometres)
    }

    /// Google Maps directions link. Opens the Google Maps app if installed, otherwise Safari.
    private var googleMapsURL: URL? {
        var components = URLComponents(string: "https://www.google.com/maps/dir/")
        components?.queryItems = [
            URLQueryItem(name: "api", value: "1"),
            URLQueryItem(name: "destination", value: "\(place.coordinate.latitude),\(place.coordinate.longitude)")
        ]
        return components?.url
    }

    /// Phone link with spaces removed, if the place has a number.
    private var phoneURL: URL? {
        guard let phone = place.phoneNumber else { return nil }
        return URL(string: "tel:\(phone.filter { !$0.isWhitespace })")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(place.name)
                .font(.title3.bold())

            if !place.address.isEmpty {
                Label(place.address, systemImage: "mappin.and.ellipse")
                    .foregroundStyle(.secondary)
            }

            if let distanceText {
                Label(distanceText, systemImage: "location")
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Button {
                    if let googleMapsURL { openURL(googleMapsURL) }
                } label: {
                    Label("Google Maps", systemImage: "car.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)

                Button {
                    place.mapItem.openInMaps(launchOptions: [
                        MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                    ])
                } label: {
                    Label("Apple Maps", systemImage: "map.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.green)
            }
            .controlSize(.large)
            .padding(.top, 4)

            if let phoneURL {
                Button {
                    openURL(phoneURL)
                } label: {
                    Label("Call", systemImage: "phone.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .tint(.green)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .presentationDetents([.height(320), .medium])
        .presentationDragIndicator(.visible)
    }
}
