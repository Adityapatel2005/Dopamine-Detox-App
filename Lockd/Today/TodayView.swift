import SwiftUI

struct TodayView: View {
    @StateObject private var viewModel = TodayViewModel()
    @State private var isShowingSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                LockdTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header
                        scoreCard
                        weakSpotCard
                        sessionCard
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Today")
            .toolbar {
                Button {
                    isShowingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(LockdTheme.secondaryText)
                }
                .accessibilityLabel("Settings")
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Protect the next block.")
                .font(.largeTitle.bold())
                .foregroundStyle(LockdTheme.primaryText)
            Text("Your next weak spot is predictable.")
                .font(.subheadline)
                .foregroundStyle(LockdTheme.secondaryText)
        }
    }

    private var scoreCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Focus Score")
                .font(.headline)
                .foregroundStyle(LockdTheme.secondaryText)
            Text("\(viewModel.focusScore)")
                .font(.system(size: 72, weight: .black, design: .rounded))
                .foregroundStyle(LockdTheme.protectedGreen)
                .accessibilityLabel("Focus Score \(viewModel.focusScore)")
            LockdButton(viewModel.buttonTitle, systemImage: "lock.fill", isLoading: viewModel.isApplyingProtection) {
                viewModel.startLockIn()
            }
        }
        .padding(18)
        .background(LockdTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: LockdTheme.cornerRadius, style: .continuous))
    }

    private var weakSpotCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("9:10 PM - high risk", systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundStyle(LockdTheme.riskOrange)
            Text("Why: \(viewModel.weakSpot.explanation)")
                .font(.subheadline)
                .foregroundStyle(LockdTheme.secondaryText)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LockdTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: LockdTheme.cornerRadius, style: .continuous))
    }

    private var sessionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(viewModel.activeSession == nil ? "No session active" : "Protected mode active")
                .font(.headline)
                .foregroundStyle(LockdTheme.primaryText)
            Text(viewModel.protectionStatusMessage)
                .font(.subheadline)
                .foregroundStyle(LockdTheme.secondaryText)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LockdTheme.elevatedSurface)
        .clipShape(RoundedRectangle(cornerRadius: LockdTheme.cornerRadius, style: .continuous))
    }
}
