import SwiftUI

struct InsightsView: View {
    @StateObject private var viewModel = InsightsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                LockdTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Weekly control")
                            .font(.largeTitle.bold())
                            .foregroundStyle(LockdTheme.primaryText)

                        metric(title: "Weekly Focus Score", value: "\(viewModel.weeklyScore)", color: LockdTheme.protectedGreen)
                        metric(title: "Time reclaimed", value: "\(viewModel.reclaimedHours)h", color: LockdTheme.insightBlue)
                        metric(title: "Protected streak", value: "\(viewModel.streakDays)d", color: LockdTheme.riskOrange)
                        metric(title: "Bypass attempts", value: "\(viewModel.snapshot.bypassAttempts)", color: LockdTheme.secondaryText)

                        VStack(alignment: .leading, spacing: 8) {
                            Label("Next weak spot", systemImage: "sparkle.magnifyingglass")
                                .font(.headline)
                                .foregroundStyle(LockdTheme.primaryText)
                            Text(viewModel.topPattern)
                                .font(.subheadline)
                                .foregroundStyle(LockdTheme.secondaryText)
                            Text(viewModel.isAdvancedInsightsLocked ? "Advanced DeviceActivityReport insights require Lockd Pro." : "DeviceActivityReport insights stay private on this iPhone.")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(viewModel.isAdvancedInsightsLocked ? LockdTheme.riskOrange : LockdTheme.protectedGreen)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(LockdTheme.elevatedSurface)
                        .clipShape(RoundedRectangle(cornerRadius: LockdTheme.cornerRadius, style: .continuous))

                        ShareCardView(score: viewModel.weeklyScore, reclaimedHours: viewModel.reclaimedHours, streakDays: viewModel.streakDays)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Insights")
        }
    }

    private func metric(title: String, value: String, color: Color) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(LockdTheme.secondaryText)
            Spacer()
            Text(value)
                .font(.title.bold())
                .foregroundStyle(color)
        }
        .padding(18)
        .background(LockdTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: LockdTheme.cornerRadius, style: .continuous))
    }
}
