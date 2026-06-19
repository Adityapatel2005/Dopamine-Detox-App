import SwiftUI

struct PaywallView: View {
    let onClose: () -> Void

    var body: some View {
        ZStack {
            LockdTheme.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 18) {
                Text("Unlock Predictive Protection")
                    .font(.largeTitle.bold())
                    .foregroundStyle(LockdTheme.primaryText)
                Text("Automatic weak-spot detection, unlimited lock-ins, advanced schedules, weekly insight cards, premium recap cards, and challenge packs.")
                    .foregroundStyle(LockdTheme.secondaryText)
                pricing(title: "$39.99 / year", subtitle: "7-day free trial. Best for Monk Mode.")
                pricing(title: "$5.99 / month", subtitle: "Flexible monthly protection.")
                LockdButton("Start 7-day trial", systemImage: "lock.open.fill") {}
                Button("Maybe later", action: onClose)
                    .foregroundStyle(LockdTheme.secondaryText)
                    .frame(maxWidth: .infinity, minHeight: LockdTheme.minimumTouchTarget)
            }
            .padding(24)
        }
    }

    private func pricing(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundStyle(LockdTheme.primaryText)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(LockdTheme.secondaryText)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LockdTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: LockdTheme.cornerRadius, style: .continuous))
    }
}
