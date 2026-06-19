import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var step = 0

    private let titles = [
        "Your weak spots are predictable.",
        "Pick three apps to guard.",
        "Choose the lock-in goal.",
        "Try a 10-minute quick lock."
    ]

    private let subtitles = [
        "Lockd helps you stop before the scroll starts.",
        "Start small. TikTok, Instagram, YouTube, Reddit, Safari, or your own selections later.",
        "Cut brain rot, study without folding, sleep without scrolling, or start Monk Mode.",
        "Feel protected now. Permissions and Pro come after the first win."
    ]

    var body: some View {
        ZStack {
            LockdTheme.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 26) {
                Spacer()
                Text(titles[step])
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(LockdTheme.primaryText)
                    .minimumScaleFactor(0.78)
                Text(subtitles[step])
                    .font(.title3)
                    .foregroundStyle(LockdTheme.secondaryText)
                Spacer()
                LockdButton(step == titles.count - 1 ? "Start Lockd" : "Continue", systemImage: "arrow.right") {
                    if step == titles.count - 1 {
                        onComplete()
                    } else {
                        step += 1
                    }
                }
            }
            .padding(24)
        }
    }
}
