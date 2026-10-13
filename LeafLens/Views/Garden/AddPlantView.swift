import SwiftUI
import SwiftData

/// Sheet for adding a new plant to the garden.
struct AddPlantView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var species = "Tomato"

    private let speciesOptions = ["Tomato", "Chilli", "Capsicum", "Long Beans", "Brinjal", "Other"]

    /// Name with spaces trimmed; Save is disabled while it is empty.
    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Plant") {
                    TextField("Name (e.g. Tomato 1)", text: $name)
                    Picker("Type", selection: $species) {
                        ForEach(speciesOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                }
            }
            .navigationTitle("New Plant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(trimmedName.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    /// Inserts the plant into SwiftData; it is saved automatically.
    private func save() {
        modelContext.insert(Plant(name: trimmedName, species: species))
        dismiss()
    }
}
