import SwiftUI
import SwiftData

/// Shows one plant's details and its scan history.
struct PlantDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let plant: Plant

    /// Newest scans first.
    private var sortedScans: [ScanRecord] {
        plant.scans.sorted { $0.date > $1.date }
    }

    var body: some View {
        List {
            Section {
                LabeledContent("Type", value: plant.species)
                LabeledContent("Added", value: plant.dateAdded.formatted(date: .abbreviated, time: .omitted))
                LabeledContent("Scans", value: "\(plant.scans.count)")
            }

            Section("Scan history") {
                if sortedScans.isEmpty {
                    Text("No scans yet. Scan a leaf from the Scan tab.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedScans) { scan in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(scan.diseaseLabel)
                                .font(.headline)
                            Text("\(scan.confidence.formatted(.percent.precision(.fractionLength(0)))) confidence · \(scan.date.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: deleteScans)
                }
            }
        }
        .navigationTitle(plant.name)
        #if DEBUG
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add sample scan", systemImage: "plus.circle") {
                    addSampleScan()
                }
            }
        }
        #endif
    }

    /// Deletes the swiped scans.
    private func deleteScans(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sortedScans[index])
        }
    }

    #if DEBUG
    /// Development helper: adds a fake scan so persistence can be tested before Core ML is added.
    private func addSampleScan() {
        let labels = ["Tomato healthy", "Tomato early blight", "Tomato late blight"]
        let scan = ScanRecord(
            diseaseLabel: labels.randomElement() ?? labels[0],
            confidence: Double.random(in: 0.6...0.98)
        )
        plant.scans.append(scan)
    }
    #endif
}
