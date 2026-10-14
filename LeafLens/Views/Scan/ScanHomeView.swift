import PhotosUI
import SwiftUI

/// Scan tab: pick a leaf photo, watch the scan animation, then see the result.
struct ScanHomeView: View {
    @State private var viewModel = ScanViewModel()
    @State private var showResult = false
    @ScaledMetric private var iconSize: CGFloat = 72

    var body: some View {
        NavigationStack {
            ScrollView {
                content
                    .padding(24)
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
            }
            .navigationTitle("Scan")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: Route.settings) {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .navigationDestination(for: Route.self) { route in
                RouteDestinationView(route: route)
            }
            .navigationDestination(isPresented: $showResult) {
                ScanResultView(viewModel: viewModel)
            }
            .onChange(of: viewModel.pickerItem) {
                Task { await viewModel.loadSelectedPhoto() }
            }
            .onChange(of: viewModel.state) { _, newState in
                if case .result = newState { showResult = true }
            }
            .onChange(of: showResult) { _, isShowing in
                if !isShowing { viewModel.reset() }
            }
        }
    }

    /// Picks the right screen for the current scan state.
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .result:
            idleView
        case .loading, .scanning:
            scanningView
        case .error(let message):
            ContentUnavailableView {
                Label("Something went wrong", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Try again") { viewModel.reset() }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
            }
        }
    }

    private var idleView: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: iconSize))
                .foregroundStyle(.green)
                .accessibilityHidden(true)

            Text("Check a leaf")
                .font(.title2.bold())

            Text("Pick a clear photo of one leaf to find out if your plant is healthy.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            PhotosPicker(selection: $viewModel.pickerItem, matching: .images) {
                Label("Choose a leaf photo", systemImage: "photo.on.rectangle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.green)
            .accessibilityIdentifier("choosePhotoButton")

            VStack(alignment: .leading, spacing: 10) {
                Text("For best results")
                    .font(.headline)
                Label("One leaf filling the frame", systemImage: "viewfinder")
                Label("Good daylight, no strong shadows", systemImage: "sun.max")
                Label("A plain background if possible", systemImage: "square.dashed")
            }
            .leafCard()
            .padding(.top, 8)
        }
    }

    private var scanningView: some View {
        VStack(spacing: 16) {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay {
                        ScanningOverlay()
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .accessibilityLabel("Selected leaf photo")
            }
            ProgressView("Analysing leaf…")
        }
    }
}

#Preview {
    ScanHomeView()
        .modelContainer(for: [Plant.self, ScanRecord.self], inMemory: true)
}
