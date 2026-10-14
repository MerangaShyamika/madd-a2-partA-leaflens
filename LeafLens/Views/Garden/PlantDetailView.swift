import Charts
import SwiftData
import SwiftUI

/// Shows one plant: a summary header, a health-trend chart and the scan history with photos.
struct PlantDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let plant: Plant

    /// Newest first, for the history list.
    private var sortedScans: [ScanRecord] {
        plant.scans.sorted { $0.date > $1.date }
    }

    /// Oldest first, for the chart.
    private var chronologicalScans: [ScanRecord] {
        plant.scans.sorted { $0.date < $1.date }
    }

    var body: some View {
        List {
            Section {
                header
            }

            if chronologicalScans.count >= 2 {
                Section("Health trend") {
                    trendChart
                }
            }

            Section("Scan history") {
                if sortedScans.isEmpty {
                    Text("No scans yet. Scan a leaf from the Scan tab and save it to this plant.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedScans) { scan in
                        scanRow(scan)
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

    /// Latest photo plus key facts and the current status.
    private var header: some View {
        HStack(spacing: 16) {
            ScanThumbnail(data: plant.latestScan?.imageData, size: 76)

            VStack(alignment: .leading, spacing: 4) {
                Text(plant.species)
                    .font(.headline)
                Text("Added \(plant.dateAdded.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(plant.scans.count) scan\(plant.scans.count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let latest = plant.latestScan {
                    Label(latest.isHealthy ? "Looks healthy" : latest.diseaseLabel,
                          systemImage: latest.isHealthy ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(latest.isHealthy ? .green : .orange)
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    /// Confidence of each scan over time. Green points are healthy, orange points are diseased.
    private var trendChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Chart(chronologicalScans) { scan in
                LineMark(
                    x: .value("Date", scan.date),
                    y: .value("Confidence", scan.confidence * 100)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.green.opacity(0.4))

                PointMark(
                    x: .value("Date", scan.date),
                    y: .value("Confidence", scan.confidence * 100)
                )
                .foregroundStyle(scan.isHealthy ? Color.green : Color.orange)
                .symbolSize(80)
            }
            .chartYScale(domain: 0...100)
            .chartYAxisLabel("Confidence %")
            .frame(height: 180)

            Label("Green = healthy, orange = disease detected", systemImage: "info.circle")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Health trend chart with \(chronologicalScans.count) scans")
    }

    private func scanRow(_ scan: ScanRecord) -> some View {
        HStack(spacing: 12) {
            ScanThumbnail(data: scan.imageData, size: 52)

            VStack(alignment: .leading, spacing: 2) {
                Text(scan.diseaseLabel)
                    .font(.headline)
                Text("\(scan.confidence.formatted(.percent.precision(.fractionLength(0)))) · \(scan.date.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: scan.isHealthy ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(scan.isHealthy ? .green : .orange)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }

    /// Deletes the swiped scans.
    private func deleteScans(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sortedScans[index])
        }
    }

    #if DEBUG
    /// Development helper: adds a fake scan to test the list and chart.
    private func addSampleScan() {
        let labels = ["Tomato healthy", "Tomato early blight", "Tomato late blight"]
        let scan = ScanRecord(
            date: .now,
            diseaseLabel: labels.randomElement() ?? labels[0],
            confidence: Double.random(in: 0.6...0.98)
        )
        plant.scans.append(scan)
    }
    #endif
}

/// Small rounded photo of a scan, or a leaf icon when there is no photo.
private struct ScanThumbnail: View {
    let data: Data?
    let size: CGFloat

    var body: some View {
        Group {
            if let data, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "leaf.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.green.opacity(0.15))
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityHidden(true)
    }
}
