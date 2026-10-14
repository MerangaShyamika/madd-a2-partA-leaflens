import MapKit
import Observation

/// Searches Apple Maps for gardening-related places in the visible map area.
@MainActor
@Observable
final class NearbyViewModel {
    enum Category: String, CaseIterable, Identifiable {
        case agroShops = "Agro shops"
        case fertilizer = "Fertilizer"
        case nurseries = "Nurseries"

        var id: String { rawValue }

        /// Text sent to Apple Maps search.
        var query: String {
            switch self {
            case .agroShops: "agro shop"
            case .fertilizer: "fertilizer"
            case .nurseries: "plant nursery"
            }
        }

        /// Icon used for this category's map pins.
        var icon: String {
            switch self {
            case .agroShops: "storefront.fill"
            case .fertilizer: "drop.fill"
            case .nurseries: "leaf.fill"
            }
        }
    }

    var category: Category = .agroShops
    var places: [Place] = []
    var isSearching = false
    var hasSearched = false
    var errorMessage: String?

    /// Runs an Apple Maps search for the current category inside the given region.
    func search(in region: MKCoordinateRegion) async {
        isSearching = true
        errorMessage = nil
        defer {
            isSearching = false
            hasSearched = true
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = category.query
        request.region = region
        request.resultTypes = .pointOfInterest

        do {
            let response = try await MKLocalSearch(request: request).start()
            places = response.mapItems.map(Place.init)
        } catch let error as MKError where error.code == .placemarkNotFound {
            places = []
        } catch {
            places = []
            errorMessage = "Search failed. Check your internet connection."
        }
    }
}
