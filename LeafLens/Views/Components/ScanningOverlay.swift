import SwiftUI

/// Animated green sweep line shown over the photo while the model runs.
struct ScanningOverlay: View {
    @State private var sweep = false

    var body: some View {
        GeometryReader { geo in
            LinearGradient(
                colors: [.clear, .green.opacity(0.6), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 60)
            .offset(y: sweep ? geo.size.height - 30 : -30)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                sweep = true
            }
        }
    }
}
