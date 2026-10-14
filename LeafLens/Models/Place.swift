import MapKit

/// A place found on the map (agro shop, fertilizer seller or nursery).
struct Place: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let phoneNumber: String?
    let mapItem: MKMapItem

    /// Builds a Place from an Apple Maps search result.
    init(mapItem: MKMapItem) {
        self.name = mapItem.name ?? "Unnamed place"
        self.address = mapItem.placemark.title ?? ""
        self.coordinate = mapItem.placemark.coordinate
        self.phoneNumber = mapItem.phoneNumber
        self.mapItem = mapItem
    }

    // CLLocationCoordinate2D is not Hashable, so compare places by id.
    static func == (lhs: Place, rhs: Place) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension MKCoordinateRegion {
    /// Default map area (Colombo) used before the user's location is known.
    static let colombo = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )
}
