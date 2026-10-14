import SwiftUI

/// One page of the onboarding flow.
struct OnboardingPage {
    let symbol: String
    let title: String
    let message: String
}

/// Three-page welcome shown on first launch, with animated icons and haptics.
struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var page = 0

    private let pages = [
        OnboardingPage(
            symbol: "leaf.circle.fill",
            title: "Check your plants",
            message: "Pick a photo of one leaf and LeafLens tells you if it looks healthy or shows signs of disease."
        ),
        OnboardingPage(
            symbol: "iphone.gen3",
            title: "Works offline",
            message: "The check runs on your iPhone, so it works in the garden without internet and your photos stay private."
        ),
        OnboardingPage(
            symbol: "map.circle.fill",
            title: "Track and get help",
            message: "Follow each plant's health over time and find agro shops and nurseries near you."
        )
    ]

    private var isLastPage: Bool { page == pages.count - 1 }

    var body: some View {
        VStack(spacing: 20) {
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPageView(page: pages[index], isActive: page == index)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button {
                if isLastPage {
                    hasSeenOnboarding = true
                } else {
                    withAnimation(.spring) { page += 1 }
                }
            } label: {
                Text(isLastPage ? "Get started" : "Next")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.green)
            .padding(.horizontal, 24)
            .accessibilityIdentifier("onboardingButton")

            Button("Skip") { hasSeenOnboarding = true }
                .foregroundStyle(.secondary)
                .opacity(isLastPage ? 0 : 1)
                .disabled(isLastPage)
        }
        .padding(.bottom, 24)
        .background(
            LinearGradient(colors: [.green.opacity(0.18), .clear], startPoint: .top, endPoint: .center)
                .ignoresSafeArea()
        )
        .sensoryFeedback(.selection, trigger: page)
    }
}

/// A single onboarding page. The icon bounces and grows when its page becomes active.
private struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool

    @ScaledMetric private var iconSize: CGFloat = 96

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: page.symbol)
                .font(.system(size: iconSize))
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: isActive)
                .scaleEffect(isActive ? 1 : 0.7)
                .opacity(isActive ? 1 : 0.4)
                .animation(.spring(duration: 0.6), value: isActive)
                .accessibilityHidden(true)

            Text(page.title)
                .font(.title.bold())
                .multilineTextAlignment(.center)

            Text(page.message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}
