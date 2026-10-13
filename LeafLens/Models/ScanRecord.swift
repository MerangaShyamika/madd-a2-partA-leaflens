import Foundation
import SwiftData

/// One leaf scan result, linked to a plant.
@Model
final class ScanRecord {
    var date: Date
    var diseaseLabel: String
    var confidence: Double
    var notes: String

    /// Photo stored outside the database file to keep it fast.
    @Attribute(.externalStorage)
    var imageData: Data?

    /// The plant this scan belongs to.
    var plant: Plant?

    init(date: Date = .now,
         diseaseLabel: String,
         confidence: Double,
         imageData: Data? = nil,
         notes: String = "") {
        self.date = date
        self.diseaseLabel = diseaseLabel
        self.confidence = confidence
        self.imageData = imageData
        self.notes = notes
    }

    /// True when the model's label says the leaf is healthy.
    var isHealthy: Bool {
        diseaseLabel.localizedCaseInsensitiveContains("healthy")
    }
}
