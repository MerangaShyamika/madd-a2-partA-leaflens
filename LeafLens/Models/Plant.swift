import Foundation
import SwiftData

/// A plant the user tracks in their garden.
@Model
final class Plant {
    var name: String
    var species: String
    var dateAdded: Date

    /// All scans of this plant. Deleting the plant also deletes its scans.
    @Relationship(deleteRule: .cascade, inverse: \ScanRecord.plant)
    var scans: [ScanRecord] = []

    init(name: String, species: String, dateAdded: Date = .now) {
        self.name = name
        self.species = species
        self.dateAdded = dateAdded
    }

    /// The most recent scan, if there is one.
    var latestScan: ScanRecord? {
        scans.max(by: { $0.date < $1.date })
    }
}
