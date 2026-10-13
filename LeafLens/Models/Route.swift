import Foundation

/// Every screen that can be pushed onto a NavigationStack in LeafLens.
/// Using one typed enum keeps navigation safe and easy to extend.
enum Route: Hashable {
    case plantDetail(Plant)
    case scanResult
    case settings
}
