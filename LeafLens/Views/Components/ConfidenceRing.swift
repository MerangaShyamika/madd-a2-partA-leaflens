import SwiftUI

/// Custom circular ring that animates from 0 to the given confidence (0...1).
struct ConfidenceRing: View {
    let confidence: Double
    var tint: Color = .green
    var lineWidth: CGFloat = 12

    @State private var progress: Double = 0
    @ScaledMetric private var size: CGFloat = 130

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                Text(progress, format: .percent.precision(.fractionLength(0)))
                    .font(.title.bold())
                    .contentTransition(.numericText(value: progress))
                Text("confidence")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                progress = confidence
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Confidence")
        .accessibilityValue(Text(confidence, format: .percent.precision(.fractionLength(0))))
    }
}

#Preview {
    ConfidenceRing(confidence: 0.87)
}
