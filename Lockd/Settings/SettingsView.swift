import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LockdTheme.background.ignoresSafeArea()
                List {
                    Section("Protection") {
                        Label("Screen Time access is mocked in this build", systemImage: "shield.lefthalf.filled")
                        Label("Family Controls entitlement comes before release", systemImage: "checkmark.seal")
                    }

                    Section("Privacy") {
                        Label("Focus Score stays private by default", systemImage: "lock.fill")
                        Label("Recap cards share only when you choose", systemImage: "square.and.arrow.up")
                    }

                    Section("Subscription") {
                        Label("Manage Pro after App Store setup", systemImage: "creditcard")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
