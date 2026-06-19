import SwiftUI

struct ShareCardView: View {
    let score: Int
    let reclaimedHours: Int
    let streakDays: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("LOCKD RECAP")
                .font(.caption.bold())
                .foregroundStyle(LockdTheme.secondaryText)
            Text("\(score)")
                .font(.system(size: 64, weight: .black, design: .rounded))
                .foregroundStyle(LockdTheme.protectedGreen)
                .accessibilityLabel("Share recap Focus Score \(score)")
            Text("\(reclaimedHours) hours reclaimed")
                .font(.title3.bold())
                .foregroundStyle(LockdTheme.primaryText)
            Text("\(streakDays)-day protected streak")
                .foregroundStyle(LockdTheme.secondaryText)
            Text("Private by default. Shared only when you choose.")
                .font(.caption)
                .foregroundStyle(LockdTheme.secondaryText)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [LockdTheme.elevatedSurface, LockdTheme.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: LockdTheme.cornerRadius, style: .continuous))
    }
}
