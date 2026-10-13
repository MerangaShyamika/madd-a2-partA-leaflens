import SwiftUI
import SwiftData

/// My Garden tab: lists saved plants with search, add and swipe-to-delete.
struct GardenListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Plant.dateAdded, order: .reverse) private var plants: [Plant]

    @State private var searchText = ""
    @State private var showingAddPlant = false

    /// Plants matching the search text (name or type).
    private var filteredPlants: [Plant] {
        guard !searchText.isEmpty else { return plants }
        return plants.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.species.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if plants.isEmpty {
                    ContentUnavailableView {
                        Label("No plants yet", systemImage: "leaf")
                    } description: {
                        Text("Add a plant to start tracking its health.")
                    } actions: {
                        Button("Add Plant") { showingAddPlant = true }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                    }
                } else {
                    List {
                        ForEach(filteredPlants) { plant in
                            NavigationLink(value: Route.plantDetail(plant)) {
                                PlantRow(plant: plant)
                            }
                        }
                        .onDelete(perform: deletePlants)
                    }
                    .searchable(text: $searchText, prompt: "Search plants")
                }
            }
            .navigationTitle("My Garden")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddPlant = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add plant")
                }
            }
            .sheet(isPresented: $showingAddPlant) {
                AddPlantView()
            }
            .navigationDestination(for: Route.self) { route in
                RouteDestinationView(route: route)
            }
        }
    }

    /// Deletes the swiped plants (their scans are deleted by the cascade rule).
    private func deletePlants(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredPlants[index])
        }
    }
}

#Preview {
    GardenListView()
        .modelContainer(for: [Plant.self, ScanRecord.self], inMemory: true)
}
