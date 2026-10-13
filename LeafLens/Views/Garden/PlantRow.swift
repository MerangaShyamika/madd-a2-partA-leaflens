import SwiftUI

/// One row in the garden list: icon, name, type and latest health status.
struct PlantRow: View {
    let plant: Plant

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .font(.title2)
                .foregroundStyle(.green)
                .frame(width: 44, height: 44)
                .background(.green.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(plant.name)
                    .font(.headline)
                Text(plant.species)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let scan = plant.latestScan {
                Image(systemName: scan.isHealthy ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(scan.isHealthy ? .green : .orange)
                    .accessibilityLabel(scan.isHealthy ? "Healthy" : "Needs attention")
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}
