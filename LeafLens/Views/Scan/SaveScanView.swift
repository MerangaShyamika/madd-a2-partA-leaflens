import SwiftData
import SwiftUI

/// Sheet for saving a scan to a new or existing plant.
struct SaveScanView: View {
    let image: UIImage?
    let prediction: Prediction?
    var onSaved: () -> Void = {}

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Plant.dateAdded, order: .reverse) private var plants: [Plant]

    @State private var newPlantName = ""

    private var trimmedName: String {
        newPlantName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("New plant") {
                    TextField("Plant name (e.g. Tomato 2)", text: $newPlantName)
                    Button("Create plant and save") { saveToNewPlant() }
                        .disabled(trimmedName.isEmpty)
                }

                if !plants.isEmpty {
                    Section("Or add to an existing plant") {
                        ForEach(plants) { plant in
                            Button {
                                save(to: plant)
                            } label: {
                                PlantRow(plant: plant)
                            }
                            .tint(.primary)
                        }
                    }
                }
            }
            .navigationTitle("Save Scan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    /// Creates a plant named by the user, using the crop from the label (e.g. "Tomato").
    private func saveToNewPlant() {
        let species = prediction?.label.components(separatedBy: " ").first ?? "Other"
        let plant = Plant(name: trimmedName, species: species)
        modelContext.insert(plant)
        save(to: plant)
    }

    /// Stores the scan, with a downscaled photo, under the chosen plant.
    private func save(to plant: Plant) {
        guard let prediction else { return }
        let record = ScanRecord(
            diseaseLabel: prediction.label,
            confidence: prediction.confidence,
            imageData: image?.jpegDataForStorage()
        )
        plant.scans.append(record)
        onSaved()
        dismiss()
    }
}
