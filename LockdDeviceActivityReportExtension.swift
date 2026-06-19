import Foundation

#if canImport(DeviceActivity) && canImport(SwiftUI)
import DeviceActivity
import SwiftUI

@main
struct LockdDeviceActivityReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        LockdWeeklyActivityReportScene { summary in
            LockdWeeklyActivityReportView(summary: summary)
        }
    }
}

struct LockdWeeklyActivityReportScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .lockdWeeklySummary
    let content: (LockdWeeklyActivitySummary) -> LockdWeeklyActivityReportView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> LockdWeeklyActivitySummary {
        LockdWeeklyActivitySummary(
            protectedMinutes: 0,
            distractingPickups: 0,
            mostGuardedCategory: "Screen Time",
            privacyPreserving: true
        )
    }

    func body(configuration: LockdWeeklyActivitySummary) -> some View {
        content(configuration)
    }
}

struct LockdWeeklyActivityReportView: View {
    let summary: LockdWeeklyActivitySummary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Lockd Weekly Summary")
                .font(.headline)
            Text("\(summary.protectedMinutes) protected minutes")
            Text("\(summary.distractingPickups) distracting pickups")
            Text(summary.privacyPreserving ? "Private on device" : "Review privacy settings")
        }
    }
}

extension DeviceActivityReport.Context {
    static let lockdWeeklySummary = Self("lockdWeeklySummary")
}
#endif
