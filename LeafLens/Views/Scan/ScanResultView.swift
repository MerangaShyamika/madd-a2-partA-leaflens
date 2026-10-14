import SwiftUI

/// Shows the prediction with an animated confidence ring, disease info and a save button.
/// Uses a side-by-side layout on wide screens (iPad or landscape).
struct ScanResultView: View {
    let viewModel: ScanViewModel

    @Environment(\.horizontalSizeClass) private var horizontalSize
    @Environment(\.verticalSizeClass) private var verticalSize
    @Environment(\.selectTab) private var selectTab

    @State private var showSaveSheet = false
    @State private var saved = false
    @State private var zoom: CGFloat = 1
    @State private var cardsVisible = false

    private var predictions: [Prediction] {
        if case .result(let predictions) = viewModel.state { return predictions }
        return []
    }

    private var isWide: Bool {
        horizontalSize == .regular || verticalSize == .compact
    }

    var body: some View {
        ScrollView {
            let layout = isWide
                ? AnyLayout(HStackLayout(alignment: .top, spacing: 24))
                : AnyLayout(VStackLayout(spacing: 20))

            layout {
                photo
                details
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Result")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSaveSheet) {
            SaveScanView(image: viewModel.selectedImage, prediction: predictions.first) {
                saved = true
            }
        }
        .sensoryFeedback(.success, trigger: saved)
        .onAppear {
            withAnimation(.spring(duration: 0.6).delay(0.3)) {
                cardsVisible = true
            }
        }
    }

    /// The scanned photo. Pinch to zoom; it springs back when released.
    @ViewBuilder
    private var photo: some View {
        if let image = viewModel.selectedImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .scaleEffect(zoom)
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in
                            zoom = min(max(value.magnification, 1), 4)
                        }
                        .onEnded { _ in
                            withAnimation(.spring) { zoom = 1 }
                        }
                )
                .zIndex(1)
                .frame(maxWidth: 420)
                .accessibilityLabel("Scanned leaf photo")
                .accessibilityHint("Pinch to zoom")
        }
    }

    @ViewBuilder
    private var details: some View {
        if let top = predictions.first {
            let info = DiseaseInfo.forLabel(top.label)
            let tint: Color = info.isHealthy ? .green : .orange

            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    ConfidenceRing(confidence: top.confidence, tint: tint)
                    Text(top.label)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)
                    Label(info.isHealthy ? "Looks healthy" : "Needs attention",
                          systemImage: info.isHealthy ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                        .font(.headline)
                        .foregroundStyle(tint)
                    if !viewModel.isConfident {
                        Label("Not sure. Try a clearer photo of a single leaf in daylight.",
                              systemImage: "questionmark.circle")
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                    }
                }
                .frame(maxWidth: .infinity)
                .leafCard()

                if cardsVisible {
                    infoCard(info)
                        .transition(.move(edge: .bottom).combined(with: .opacity))

                    if predictions.count > 1 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Other possibilities")
                                .font(.headline)
                                .accessibilityAddTraits(.isHeader)
                            ForEach(predictions.dropFirst()) { prediction in
                                HStack {
                                    Text(prediction.label)
                                    Spacer()
                                    Text(prediction.confidence, format: .percent.precision(.fractionLength(0)))
                                        .foregroundStyle(.secondary)
                                }
                                .accessibilityElement(children: .combine)
                            }
                        }
                        .leafCard()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }

                Button {
                    showSaveSheet = true
                } label: {
                    Label(saved ? "Saved to garden" : "Save to garden",
                          systemImage: saved ? "checkmark" : "tray.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.green)
                .disabled(saved)
                .accessibilityIdentifier("saveScanButton")

                if !info.isHealthy {
                    Button {
                        selectTab(.nearby)
                    } label: {
                        Label("Find help nearby", systemImage: "map")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .tint(.green)
                    .accessibilityHint("Shows agro shops and nurseries near you")
                    .accessibilityIdentifier("findHelpButton")
                }
            }
        }
    }

    private func infoCard(_ info: DiseaseInfo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Text(info.summary)

            if !info.symptoms.isEmpty {
                Text("Signs")
                    .font(.headline)
                    .padding(.top, 4)
                    .accessibilityAddTraits(.isHeader)
                ForEach(info.symptoms, id: \.self) { symptom in
                    Label(symptom, systemImage: "eye")
                }
            }

            Text("What to do")
                .font(.headline)
                .padding(.top, 4)
                .accessibilityAddTraits(.isHeader)
            ForEach(info.actions, id: \.self) { action in
                Label(action, systemImage: "checkmark.circle")
            }

            Text("General guidance only. Confirm with your local agriculture instructor before using any treatment.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .leafCard()
    }
}
