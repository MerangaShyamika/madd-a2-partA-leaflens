import SwiftUI

/// Custom modifier giving LeafLens cards one consistent look.
struct LeafCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Color(.secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
    }
}

extension View {
    /// Applies the shared LeafLens card style.
    func leafCard() -> some View {
        modifier(LeafCardModifier())
    }
}
