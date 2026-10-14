import SwiftUI

/// The app's three tabs.
enum AppTab: Hashable {
    case scan
    case garden
    case nearby
}

extension EnvironmentValues {
    /// Lets any screen switch tabs, e.g. the result screen jumping to Nearby.
    @Entry var selectTab: (AppTab) -> Void = { _ in }
}
